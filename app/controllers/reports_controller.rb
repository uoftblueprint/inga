class ReportsController < ApplicationController
  before_action :set_report, only: %i[show edit update destroy]

  def index
    @reports = Report.all
  end

  def show; end

  def new
    @report = Report.new
  end

  def edit; end

  def create
    @report = Report.new(report_params)
    if @report.save
      redirect_to reports_path, flash: { success: t(".success") }
    else
      flash.now[:error] = @report.errors.full_messages.to_sentence
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @report.update(report_params)
      redirect_to reports_path, flash: { success: t(".success") }
    else
      flash.now[:error] = @report.errors.full_messages.to_sentence
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @report.destroy
      redirect_to reports_path, flash: { success: t(".success") }
    else
      redirect_to reports_path, flash: { error: @report.errors.full_messages.to_sentence }
    end
  end

  private

  def set_report
    @report = Report.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to reports_path, flash: { error: t("reports.not_found") }
  end

  def report_params
    params.expect(report: %i[start_date end_date])
  end

  def has_required_roles?
    current_user.has_roles?(:admin)
  end
end

class ReportsController < ApplicationController
  def show
    @report = Report.find(params[:id])
  end

  private

  def has_required_roles?
    current_user.has_roles?(:admin)
  end
end
