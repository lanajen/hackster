class FavoritesController < ApplicationController
  before_filter :authenticate_user!
  before_filter :load_project
  respond_to :html, :json

  def create
#    authorize! :create,
    current_user.add_favorite @project

    respond_to do |format|
      format.html { redirect_to @project, notice: "You added #{@project.name} to your favorites." }
      format.js { render 'button' }
    end
  end

  def destroy
    current_user.remove_favorite @project

    respond_to do |format|
      format.html { redirect_to @project, notice: "You removed #{@project.name} from your favorites." }
      format.js { render 'button' }
    end

  end
end