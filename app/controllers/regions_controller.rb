class RegionsController < ApplicationController
  def index
    @regions = Region.all
  end

  def new
    @region = Region.new
  end

  def create
    @region = Region.new(region_params)

    if @region.save
      redirect_to(
        regions_path,
        flash: { success: t(".success") }
      )
    else
      flash.now[:error] = t(".error")
      render :new, status: :unprocessable_entity
    end
  end

  private

  def region_params
    params.expect(region: %i[name latitude longitude])
  end

  def has_required_roles?
    current_user.has_roles?(:admin)
  end
end
