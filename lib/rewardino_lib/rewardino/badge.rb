module Rewardino
  require 'ambry'
  require 'ambry/active_model'

  class Badge
    LEVELS = %i(green bronze silver gold)

    extend Ambry::Model
    extend Ambry::ActiveModel

    field :code, :name_, :description_, :condition, :disabled, :levels, :image,
      :revokable, :custom_fields, :explanation_

    validates_presence_of :code
    validates_uniqueness_of :code

    filters do
      def by_code code
        find { |b| b.code.to_s == code.to_s }
      end

      def by_level level
        find { |b| level.to_s.in? b.levels.keys.map(&:to_s) }
      end
    end

    class << self
      alias_method :find_key, :find

      def find code
        find_key code.to_sym
      end
    end

    %w(name description explanation).each do |attribute|
      define_method "#{attribute}" do |level|
        level = level.to_sym
        if levels[level].kind_of? Hash
          levels[level][:"#{attribute}_"]
        else
          threshold = threshold_for_level level
          eval "
            send(:#{attribute}_).gsub(/\\|threshold\\|/, '#{threshold}')
          "
        end
      end
    end

    def get_image
      attributes['image'].presence || Rewardino.default_image
    end

    def next_level current_level
      i = levels.keys.index(current_level.to_sym)
      levels.keys[i + 1]
    end

    def previous_level current_level
      i = levels.keys.index(current_level.to_sym)
      levels.keys[i - 1]
    end

    def threshold_for_level level
      threshold = levels[level.to_sym]
      case threshold
      when Hash
        threshold[:threshold]
      else
        threshold
      end
    end
  end
end