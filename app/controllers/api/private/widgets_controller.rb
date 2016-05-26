# delete this controller after medium.js has been fully removed
class Api::Private::WidgetsController < Api::Private::BaseController
  before_filter :authenticate_user!
  load_and_authorize_resource except: [:create]

  def create
    @widget = Widget.new params[:widget]
    authorize! :create, @widget

    @widget.save

    if @widget.type == 'PartsWidget'
      @widget.parts.create quantity: 1
    end

    embed = Embed.new widget: @widget
    code = render_to_string partial: "api/embeds/embed", formats: :html, locals: { embed: embed, options: { mode: :edit } }
    render json: embed.to_json.merge(code: code, widget_id: embed.widget.id, widget_type: embed.widget.type)
  end

  def update
    if @widget.update_attributes params[:widget]
      render json: @widget.to_json, status: :ok
    else
      render json: @widget.errors, status: :bad_request
    end
  end

  def destroy
    @widget.destroy if @widget.type != 'PartsWidget'

    render status: :ok, text: ''
  end
end