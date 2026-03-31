class ReporterDashboardsController < ApplicationController
  def show; end

  private

  def has_required_roles? = current_user.has_roles?(:reporter)
end