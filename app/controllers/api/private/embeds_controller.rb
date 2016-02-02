class Api::Private::EmbedsController < Api::Private::BaseController
  def show
    embed = Embed.new url: params[:url], widget_id: params[:widget_id]
    if embed.for_text_editor?
      code = render_to_string partial: "api/embeds/embed", locals: { embed: embed, options: {} }
      render json: embed.to_json.merge(code: code)
    else
      render json: { url: params[:url] }
    end
  end
end