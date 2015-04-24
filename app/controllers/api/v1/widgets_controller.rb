class Api::V1::WidgetsController < Api::V1::BaseController
  before_filter :authenticate_user!
  load_and_authorize_resource except: [:create]

  def create
    @widget = Widget.new params[:widget]
    authorize! :create, @widget

    @widget.save

    if @widget.type == 'PartsWidget'
      @widget.parts.create quantity: 1
    end

    embed = Embed.new widget_id: @widget.id
    code = render_to_string partial: "api/embeds/embed", locals: { embed: embed }
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