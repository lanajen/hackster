class Api::V2::PartsController < Api::V2::BaseController
  before_filter :doorkeeper_authorize_without_scope!
  before_filter :load_and_authorize_resource

  def index
    if params[:q].present?
      type = params[:type] ? params[:type].capitalize + 'Part' : nil
      platform_id = params[:all_platforms] ? nil : current_platform.try(:id)
      @parts = Part.search(q: params[:q], type: type, platform_id: platform_id, per_page: 10, includes: [:image, platform: :avatar])

      render 'api/v1/parts/index_search'
    else
      @parts = if current_platform
        current_platform.parts
      else
        Part
      end

      if params[:type].present?
        if params[:type].in? Part::KNOWN_TYPES
          params[:human_type] = Part::KNOWN_TYPES[params[:type]]
          params[:type] = params[:type].capitalize + 'Part'

          @parts = @parts.where(type: params[:type])
        else
          params[:human_type] = params[:type]
        end
      end

      sort = params[:sort]
      unless sort.in? Part::SORTING.keys
        sort = Part::DEFAULT_SORT
      end
      @parts = @parts.send(Part::SORTING[sort])

      if params[:approved]
        @parts = @parts.approved
      end

      @parts = @parts.includes(:image, platform: :avatar).paginate(page: safe_page_params)

      render 'api/v1/parts/index'
    end
  end

  def create
    if @part.save
      render status: :ok, template: 'api/v1/parts/show'
    else
      render status: :unprocessable_entity, json: { part: @part.errors }
    end
  end

  def update
    if @part.update_attributes params[:part]
      render status: :ok, template: 'api/v1/parts/show'
    else
      render status: :unprocessable_entity, json: { part: @part.errors }
    end
  end

  def destroy
    @part.destroy

    render status: :ok, nothing: true
  end

  private
    def load_and_authorize_resource
      @part = if params[:id].present?
        Part.find params[:id]
      else
        Part.new params[:part]
      end
      authorize! self.action_name.to_sym, @part
    end
end