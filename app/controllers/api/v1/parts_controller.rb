class Api::V1::PartsController < Api::V1::BaseController

  def index
    @parts = if params[:q].present?
      if params[:type].present?
        params[:human_type] = {
          'hardware' => 'component',
          'software' => 'app',
          'tool' => 'tool',
        }[params[:type]]
        params[:type] = params[:type].capitalize + 'Part'
      end

      Part.search(q: params[:q], type: params[:type]).paginate(page: safe_page_params)
    else
      []
    end
  end

  def create
    @part = Part.new params[:part]

    if @part.save
      render status: :ok, template: 'api/v1/parts/show'
    else
      render status: :unprocessable_entity, json: { part: @part.errors }
    end
  end

  def update
    @part = Part.find params[:id]

    if @part.update_attributes params[:part]
      render status: :ok, template: 'api/v1/parts/show'
    else
      render status: :unprocessable_entity, json: { part: @part.errors }
    end
  end

  def destroy
    part = Part.find params[:id]
    part.destroy

    render status: :ok, nothing: true
  end
end