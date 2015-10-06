class Groups::PartsController < ApplicationController
  before_filter :load_platform
  load_resource except: [:index]

  def index
    authorize! :manage, @platform

    @parts = @platform.parts.alphabetical.with_slug.paginate(page: safe_page_params)
  end

  def create
    @part.platform_id = @platform.id
    @part.generate_slug

    if @part.save
      redirect_to group_products_path(@platform), notice: "#{@part.name} created!"
    else
      render :new
    end
  end

  def update
    if @part.update_attributes(params[:part])
      redirect_to group_products_path(@platform), notice: "#{@part.name} saved!"
    else
      render :edit
    end
  end

  private
    def load_platform
      @group = @platform = Platform.find(params[:group_id] || params[:id])
      authorize! :manage, @platform
    end
end