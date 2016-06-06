class Groups::PartsController < MainBaseController
  before_filter :load_platform
  load_resource except: [:index]

  def index
    authorize! :manage, @platform

    @parts = @platform.parts.alphabetical.with_slug.paginate(page: safe_page_params)

    @parts_pending_review = @platform.parts.with_slug.where(workflow_state: :pending_review).exists?
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

  def destroy
    @part.destroy

    redirect_to group_products_path(@platform), notice: "#{@part.name} deleted!"
  end

  private
    def load_platform
      @group = @platform = Platform.find(params[:group_id] || params[:id])
      authorize! :manage, @platform
    end
end