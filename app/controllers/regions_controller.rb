class RegionsController < ApplicationController
  def index
    @regions = Region.all
  end

  def has_required_roles?
    current_user.has_roles?(:admin)
  end
end
