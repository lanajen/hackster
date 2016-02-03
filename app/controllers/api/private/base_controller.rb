class Api::Private::BaseController < Api::BaseController
  before_filter :private_api_methods
end