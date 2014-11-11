module Rewardino
  # Sets up an app-wide after_filter, and checks rules if
  # there are defined rules (for badges or points) for current
  # 'controller_path#action_name'
  module ControllerExtension
    def self.included(base)
      # puts 'included!'
      base.append_after_filter do |controller|

        # puts 'triggers: ' + matching_triggers.to_s
        matching_triggers.each do |trigger|
          # puts 'trigger: ' + trigger.inspect
          next if trigger.condition.present? and !trigger.condition.call(controller)

          user_method = Rewardino.current_user_method(trigger)
          users = Array.wrap(if user_method[0] == '@'
            controller.instance_variable_get user_method
          else
            send user_method
          end).compact
          next unless users.any?

          users.each do |user|
            # puts 'user: ' + user.inspect
            if trigger.action == :set_badge
              if trigger.background
                # RewardinoQueue.perform_async 'evaluate_badge', user.id, trigger.badge_code
                User.delay.evaluate_badge user.id, trigger.badge_code
              else
                status = user.evaluate_badge trigger.badge_code
                # puts 'status: ' + status.inspect
                if status.class == Rewardino::StatusAwarded
                  session[:new_badge] = status.badge
                elsif status.class == Rewardino::StatusTakenAway
                  session[:new_badge] = status.badge
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