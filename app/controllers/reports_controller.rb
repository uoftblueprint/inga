class ReportsController < ApplicationController
  before_action :set_report, only: %i[show edit update destroy]

  def index
    @reports = Report.all
  end

  def show
    @report = Report.find(params[:id])
  end

  def new; end

  # TODO: implement full edit page
  def edit
    @report = Report.find(params[:id])
    render :show
  end

  def filter
    start_date = parse_date(params[:start_date])
    end_date = parse_date(params[:end_date])

    if start_date && end_date && start_date <= end_date
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

    render :new
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

  private

  def parse_date(value)
    Date.parse(value)
  rescue Date::Error, TypeError
    nil
  end

  def has_required_roles?
    current_user.has_roles?(:admin)
  end
end
