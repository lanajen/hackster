class SlugsController < ApplicationController
  before_filter :load_sluggable

  def show
    case @sluggable
    when User
      UsersController.new.show
    when Tech
      TechesController.new.show
    end
  end

  private
    def load_sluggable
      @sluggable = load_with_slug
    end
end