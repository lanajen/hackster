class EmbedWidgetsController < MainBaseController

  def index
    @iframe_url = '/users/' + current_user.id.to_s + '/embed'
  end

end

