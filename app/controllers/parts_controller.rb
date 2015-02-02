class PartsController < ApplicationController
  before_filter :load_platform
  load_and_authorize_resource

  def index
    @parts = @platform.parts.paginate(page: safe_page_params)
  end

  def show
  end

  def new
  end

  def create
    @part.platform_id = @platform.id

    if @part.save
      redirect_to group_parts_path(@platform), notice: "#{@part.name} created!"
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @part.update_attributes(params[:part])
      redirect_to group_parts_path(@platform), notice: "#{@part.name} saved!"
    else
      render :edit
    end
  end

  def destroy
  end

  private
    def load_platform
      @group = @platform = Platform.find(params[:group_id] || params[:id])
    end
end