class ReportsController < ApplicationController
  def index
    @reports = Report.all
  end

  def show
    @report = Report.find(params[:id])
  end

  def new
    start_date = parse_date(params[:start_date])
    end_date = parse_date(params[:end_date])

    return unless start_date && end_date && start_date <= end_date

    @start_date = params[:start_date]
    @end_date = params[:end_date]

    result = ReportFilterService.new.filter(
      start_date: start_date,
      end_date: end_date,
      project_ids: Array(params[:project_ids]),
      subproject_ids: Array(params[:subproject_ids])
    )

    @projects = result.projects
    @selected_project_ids = result.selected_project_ids
    @subprojects = result.subprojects
    @selected_subproject_ids = result.selected_subproject_ids
  end

  def edit
    @report = Report.find(params[:id])
    load_edit_context
  end

  def create
    start_date = parse_date(params[:start_date])
    end_date = parse_date(params[:end_date])
    subproject_ids = Array(params[:subproject_ids]).map(&:to_i)

    unless start_date && end_date && start_date <= end_date && subproject_ids.any?
      redirect_to new_report_path, flash: { error: t(".invalid") }
      return
    end

    subprojects = Subproject.where(id: subproject_ids)

    unless subprojects.exists?
      redirect_to new_report_path, flash: { error: t(".invalid") }
      return
    end

    report = nil
    ActiveRecord::Base.transaction do
      report = Report.create!(start_date: start_date, end_date: end_date)

      journals = Journal.where(subproject: subprojects, created_at: start_date.beginning_of_day..end_date.end_of_day)
      report.journals << journals

      metadata_service = LogEntryMetadataService.new
      categorized = metadata_service.retrieve_categorized_metadata_for_range(
        subprojects, start_date.beginning_of_day, end_date.end_of_day
      )

      Aggregators::NumericalAggregator.new(report: report, data: categorized.numerical).aggregate
      Aggregators::BooleanAggregator.new(report: report, data: categorized.boolean).aggregate
    end

    redirect_to edit_report_path(report), flash: { success: t(".success") }
  end

  def update
    @report = Report.find(params[:id])

    journals = Journal.where(id: selected_journal_ids)
    aggregated_data = parse_new_aggregated_data

    unless aggregated_data
      redirect_to edit_report_path(@report), flash: { error: t(".invalid") }
      return
    end

    ActiveRecord::Base.transaction do
      @report.journal_ids = journals.pluck(:id)

      @report.aggregated_data.where.not(id: retained_aggregated_datum_ids).delete_all

      aggregated_data.each do |datum|
        @report.aggregated_data.create!(
          type: "AggregatedNumericalDatum",
          additional_text: datum[:additional_text],
          value: datum[:value]
        )
      end
    end

    redirect_to report_path(@report), flash: { success: t(".success") }
  end

  def destroy
    @report = Report.find(params[:id])

    if @report.destroy
      redirect_to reports_path, flash: { success: t(".success") }
    else
      redirect_to reports_path, flash: { error: @report.errors.full_messages.to_sentence }
    end
  end

  private

  def load_edit_context
    selected_ids = @report.journal_ids

    @selected_journals = @report.journals.with_rich_text_markdown_content.includes(:user).order(created_at: :desc)
    @available_journals = Journal.where.not(id: selected_ids)
                                 .with_rich_text_markdown_content
                                 .includes(:user)
                                 .order(created_at: :desc)
  end

  def parse_date(value)
    Date.parse(value)
  rescue Date::Error, TypeError
    nil
  end

  def update_params
    params.permit(journal_ids: [], retained_aggregated_datum_ids: [], new_aggregated_data: {})
  end

  def selected_journal_ids
    Array(update_params[:journal_ids]).map(&:to_i)
  end

  def retained_aggregated_datum_ids
    Array(update_params[:retained_aggregated_datum_ids]).map(&:to_i)
  end

  def parse_new_aggregated_data
    parsed = []

    raw_entries_param = update_params[:new_aggregated_data]

    return [] if raw_entries_param.nil?

    raw_entries_param.each_value do |entry|
      raw_value = entry["value"].to_s.strip
      additional_text = entry["additional_text"].to_s.strip

      # error out if field missing in an aggregated datum block
      return nil if additional_text.blank? || raw_value.blank?

      value = BigDecimal(raw_value, exception: false)

      return nil unless value

      parsed << { additional_text: additional_text, value: value }
    end

    parsed
  end

  def has_required_roles?
    current_user.has_roles?(:admin)
  end
end
