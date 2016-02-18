class Api::V1::PartsController < Api::V1::BaseController
  before_filter :authenticate_platform_or_user, only: [:index]
  before_filter :authenticate_and_load_resource, only: [:show, :create, :update, :destroy]
  skip_before_filter :public_api_methods
  before_filter :public_or_private_api_methods

  def index
    if params[:q].present?
      type = params[:type] ? params[:type].capitalize + 'Part' : nil
      platform_id = params[:all_platforms] ? nil : current_platform.try(:id)
      @parts = Part.search(q: params[:q], type: type, platform_id: platform_id, per_page: 10, includes: [:image, platform: :avatar])

      render 'index_search'
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
    def authenticate_and_load_resource
      authenticate_platform_or_user
      load_and_authorize_resource
    end

    def load_and_authorize_resource
      if current_platform
        @part = if params[:id].present?
          current_platform.parts.where(parts: { id: params[:id ]}).first!
        else
          part = current_platform.parts.new params[:part]
          part.generate_slug
          part
        end
      else
        @part = if params[:id].present?
          Part.find params[:id]
        else
          Part.new params[:part]
        end
      end
      authorize! self.action_name.to_sym, @part
    end
end