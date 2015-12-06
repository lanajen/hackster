module Rewardino
  module Nominee

    def self.included base
      base.class_eval do
        has_many :awarded_badges, as: :awardee, dependent: :delete_all
        has_many :reputation_events, dependent: :delete_all

        def self.evaluate_badge id, *args
          nominee = find id
          nominee.evaluate_badge *args
        end
      end
    end

    def badges level=nil
      user_badges = awarded_badges
      user_badges = user_badges.where(level: level) if level
      user_badges = user_badges.map(&:badge)
      user_badges
    end

    def evaluate_badge badge_or_code, opts={}
      send_notification = opts[:send_notification]

      badge = case badge_or_code
      when Rewardino::Badge
        badge_or_code
      else
        Rewardino::Badge.find badge_or_code
      end

      revokable = badge.respond_to?(:revokable) and badge.revokable

      # if there's an existing badge...
      if existing_badge = has_badge?(badge.code)
        # if the badge can be taken away
        if revokable
          threshold = badge.threshold_for_level(existing_badge.level)
          # if the condition doesn't evaluate anymore
          unless evaluate_badge_condition(badge, threshold)
            # if there's a previous level go back to it
            if previous_level = badge.previous_level(existing_badge.level)
              existing_badge.update_column :level, previous_level
            # otherwise just destroy it
            else
              existing_badge.destroy
            end
            return Rewardino::StatusTakenAway.new existing_badge
          end
        end

        # if there's a next level evaluate it
        if next_level = existing_badge.badge.next_level(existing_badge.level)
          evaluate_badge_levels badge, existing_badge, next_level, send_notification
        # otherwise we're good
        else
          Rewardino::StatusAlreadyAwarded.new existing_badge
        end
      else
        evaluate_badge_levels badge, nil, nil, send_notification
      end
    end

    def has_badge? badge_or_code
      badge_code = case badge_or_code
      when Rewardino::Badge
        badge_or_code.code
      else
        badge_or_code.to_s
      end

      awarded_badges.where(badge_code: badge_code).first
    end

    private
      def evaluate_badge_condition badge, threshold
        if badge.respond_to?(:condition) and badge.condition.present?
          begin
            badge.condition.call self, threshold
          rescue => e
            ::Rewardino::StatusError.new
            puts "Error evaluating badge #{badge.inspect} at #{threshold}: " + e.inspect
            false
          end
        else
          false
        end
      end

      def evaluate_badge_levels badge, existing_badge=nil, start_level=nil, send_notification=false
        levels = if start_level
          # get the levels starting from start_level
          i = badge.levels.keys.index(start_level)
          Hash[badge.levels.to_a[i..-1]]
        else
          badge.levels
        end

        top_level = nil
        # evaluate all levels; keep going until one doesn't evaluate
        levels.each do |level, _threshold|
          threshold = _threshold.kind_of?(Hash) ? _threshold[:threshold] : _threshold
          if evaluate_badge_condition(badge, threshold)
            top_level = level
          else
            break
          end
        end

        # if a level did evaluate
        if top_level
          # update the badge if it exists, otherwise create it
          awarded_badge = if existing_badge
            existing_badge.update_column :level, top_level
            existing_badge.send_notification = send_notification
            existing_badge
          else
            AwardedBadge.create!(awardee_type: self.class.name,
              awardee_id: id, badge_code: badge.code, level: top_level,
              send_notification: send_notification)
          end
          return Rewardino::StatusAwarded.new awarded_badge
        end

        # if nothing evaluates
        Rewardino::StatusNotAwarded
      end
  end
end
