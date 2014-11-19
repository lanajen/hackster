module Rewardino
  class Trigger
    attr_accessor :event, :action, :badge_codes, :nominee_variable, :background,
      :condition

    class << self
      # all defined triggers
      def all
        @@defined_triggers ||= {}
      end

      def find_all event
        all.select{|trigger_event, trigger| event == trigger_event}.values.flatten
      end

      # Define events when badges are evaluated
      def set events, *args
        options = args.extract_options!

        trigger = Trigger.new
        %w(badge_codes nominee_variable action background condition).each do |opt|
          trigger.send "#{opt}=", options[opt.to_sym]
        end

        trigger.badge_codes = Array.wrap trigger.badge_codes

        Array.wrap(events).each do |event|
          all[event] ||= []
          all[event] << trigger
        end
      end
    end

    # Get rule's related Badge.
    def badges
      @badges ||= badge_codes.map{|bade_code| Rewardino::Badge.find(badge_code) }
    end
  end
end