class Api::V1::PartsController < Api::V1::BaseController

  def autocomplete
    parts = if params[:q].present?
      Part.search(q: params[:q], type: params[:type])
    else
      []
    end

    term = params[:type].gsub(/Part/, '').downcase
    term = {
      'hardware' => 'component',
      'software' => 'app',
      'tool' => 'tool',
    }[term]

    if parts.any?
      parts_json = parts.map{|p| { id: p.id, text: p.full_name } }
      parts_json << { id: '-1', text: "Can't find the right one? <a href='#' class='new-part-modal-toggle btn btn-sm btn-success' data-target= '#new-#{term}-modal' data-toggle='modal' data-value='#{params[:q]}'>Create a new #{term}</a>".html_safe, disabled: true }
    else
      parts_json = [{ id: '-1', text: "No results for \"#{params[:q]}\". <a href='#' class='new-part-modal-toggle btn btn-sm btn-success' data-target= '#new-#{term}-modal' data-toggle='modal' data-value='#{params[:q]}'>Create a new #{term}</a>".html_safe, disabled: true }]
    end

    render json: parts_json, root: false
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