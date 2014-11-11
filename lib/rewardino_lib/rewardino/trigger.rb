module Rewardino
  class Trigger
    attr_accessor :event, :action, :badge_code, :nominee_variable, :background

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
        %w(badge_code nominee_variable action background).each do |opt|
          trigger.send "#{opt}=", options[opt.to_sym]
        end

        Array.wrap(events).each do |event|
          all[event] ||= []
          all[event] << trigger
        end
      end
    end

    # Get rule's related Badge.
    def badge
      @badge ||= Rewardino::Badge.find(badge_code)
    end
  end
end