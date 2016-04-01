class EmbedWidgetsController < ApplicationController

  def index
    @iframe_url = 'http://www.localhost.local:5000/users/'+ current_user.id.to_s + '/embed'
  end

end

