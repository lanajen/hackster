class Api::V1::PartsController < Api::V1::BaseController
  before_filter :authenticate_user!, only: [:create, :update, :destroy]
  load_and_authorize_resource only: [:create, :update, :destroy]

  def index
    @parts = Part.approved

    if params[:q].present?
      @parts = @parts.search(q: params[:q])
    end

    if params[:type].present?
      params[:human_type] = {
        'hardware' => 'component',
        'software' => 'app',
        'tool' => 'tool',
      }[params[:type]]
      params[:type] = params[:type].capitalize + 'Part'

      @parts = @parts.where(type: params[:type])
    end

    if params[:sort]
      @parts = @parts.send(Part::SORTING[params[:sort]])
    end

    @parts = @parts.paginate(page: safe_page_params)
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
    part.destroy

    render status: :ok, nothing: true
  end
end