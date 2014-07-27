class Api::V1::EmbedsController < Api::V1::BaseController
  def show
    embed = Embed.new url: params[:url], widget_id: params[:widget_id]
    if embed.provider
      code = render_to_string partial: "api/embeds/embed", locals: { embed: embed }
      render json: embed.to_json.merge(code: code)
    else
      render json: { url: params[:url] }
    end
  end

  def create
    embed = Embed.new new_widget: params[:type], project_id: params[:project_id]
    code = render_to_string partial: "api/embeds/embed", locals: { embed: embed }
    render json: embed.to_json.merge(code: code, widget_id: embed.widget.id, widget_type: embed.widget.type)
  end
end