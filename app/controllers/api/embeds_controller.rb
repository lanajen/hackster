class Api::EmbedsController < Api::BaseController
  def show
    embed = Embed.new params[:url]
    render json: embed.to_json
  end
end