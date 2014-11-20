module Rewardino
  # Sets up an app-wide after_filter, and checks rules if
  # there are defined rules (for badges or points) for current
  # 'controller_path#action_name'
  module ControllerExtension
    def self.included(base)
      base.append_after_filter do |controller|
        if ::Rewardino.activated?
          matching_triggers.each do |trigger|
            next if trigger.condition.present? and !trigger.condition.call(controller)

            user_method = Rewardino.current_user_method(trigger)
            users = Array.wrap(if user_method[0] == '@'
              controller.instance_variable_get user_method
            else
              send user_method
            end).compact
            next unless users.any?

            users.each do |user|
              if trigger.action == :set_badge
                if trigger.background
                  User.delay.evaluate_badge user.id, trigger.badge_code
                else
                  status = user.evaluate_badge trigger.badge_code
                  if status.class == Rewardino::StatusAwarded
                    session[:new_badge] = status.badge.code
                  elsif status.class == Rewardino::StatusTakenAway
                    session[:new_badge] = status.badge.code
                  end
                end
              end
            end
          end
        end
      end
    end

    private
      def controller_action
        "#{controller_path}##{action_name}"
      end

      def matching_triggers
        @matching_triggers ||= ::Rewardino::Trigger.find_all controller_action
      end
  end
end