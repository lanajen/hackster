class PagesController < ApplicationController
  def home
    redirect_to current_user
  end
end
