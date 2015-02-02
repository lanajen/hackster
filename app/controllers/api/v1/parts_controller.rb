class Api::V1::PartsController < Api::V1::BaseController

  def autocomplete
    parts = if params[:q].present?
      Part.search(q: params[:q])
    else
      []
    end

    parts_json = if parts.any?
      parts.map{|p| { id: p.id, text: p.name } }
    else
      [{ id: '-1', text: "No results for #{params[:q]}. <a href='#' class='new-part-modal-toggle btn btn-sm btn-success' data-target='#new-part-modal' data-toggle='modal'>Create a new part</a>".html_safe, disabled: true }]
    end

    render json: parts_json
  end

  def create
    part = Part.new params[:part]

    if part.save
      render json: part.to_json
    else
      render status: :unprocessable_entity, json: { part: part.errors }
    end
  end

  def destroy
    part = Part.find params[:id]
    part.destroy

    render status: :ok, text: ''
  end
end