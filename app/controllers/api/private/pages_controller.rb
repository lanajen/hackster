class Api::Private::PagesController < Api::Private::BaseController
  def csrf
    render json: form_authenticity_token
  end
end