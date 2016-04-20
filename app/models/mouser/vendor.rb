require 'hashie/dash'

module Mouser
  class Vendor < Hashie::Dash
    property :user_name
    property :name
    property :logo_url
    property :website
    property :board_name
    property :board_image_url
    property :board_description

    def full_name
      "#{name} #{board_name}"
    end
  end
end