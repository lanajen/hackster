class Api::Private::PagesController < Api::Private::BaseController
  def csrf
    render text: form_authenticity_token
  end
end