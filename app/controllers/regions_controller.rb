class RegionsController < ApplicationController
  def index
    @regions = Region.all
  end

  def new
    @region = Region.new
  end

  def edit
    @region = Region.find(params[:id])
  end

  def create
    @region = Region.new(region_params)

    if @region.save
      redirect_to(
        regions_path,
        flash: { success: t(".success") }
      )
    else
      flash.now[:error] = @region.errors.full_messages.join(", ")
      render :new, status: :unprocessable_entity
    end
  end

  def update
    @region = Region.find(params[:id])

    if @region.update(region_params)
      redirect_to(
        regions_path,
        flash: { success: t(".success") }
      )
    else
      flash.now[:error] = @region.errors.full_messages.join(", ")
      render :edit, status: :unprocessable_entity
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
