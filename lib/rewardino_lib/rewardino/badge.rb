module Rewardino
  require 'ambry'
  require 'ambry/active_model'

  class Badge
    extend Ambry::Model
    extend Ambry::ActiveModel

    field :code, :name, :description, :condition, :disabled, :level, :image,
      :revokable, :custom_fields

    validates_presence_of :code
    validates_uniqueness_of :code

    filters do
      def by_code code
        find { |b| b.code.to_s == code.to_s }
      end

      def by_level level
        find { |b| b.level.to_s == level.to_s }
      end
    end

    class << self
      alias_method :find_key, :find

      def find code
        find_key code.to_sym
      end
    end

    def get_image
      attributes['image'].presence || Rewardino.default_image
    end
  end
end