class RegionsController < ApplicationController
  def index
    @regions = Region.all
  end

  def new
    @region = Region.new
    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end

  def edit
    @region = Region.find(params[:id])
    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end

  def create
    @region = Region.new(region_params)

    if @region.save
      redirect_to(
        regions_path,
        flash: { success: t(".success") }
      )
    else
      flash.now[:error] = @region.errors.full_messages.to_sentence
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
      flash.now[:error] = @region.errors.full_messages.to_sentence
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @region = Region.find(params[:id])

    if @region.destroy
      redirect_to(regions_path, flash: { success: t(".success") })
    else
      redirect_to(regions_path, flash: { error: @region.errors.full_messages.to_sentence })
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
