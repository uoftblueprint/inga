class ReporterDashboardsController < ApplicationController
  def show; end

  private

  def has_required_roles? = reporter?
end
