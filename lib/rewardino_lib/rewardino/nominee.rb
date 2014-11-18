module Rewardino
  module Nominee

    def self.included base
      base.class_eval {
        has_many :awarded_badges, as: :awardee
      }
    end

    def self.evaluate_badge id, *args
      nominee = self.class.find id
      nominee.evaluate_badge *args
    end

    def badges level=nil
      user_badges = awarded_badges.map(&:badge)
      user_badges = user_badges.select{|b| b.level == level } if level
      user_badges
    end

    def evaluate_badge badge_or_code
      badge = case badge_or_code
      when Rewardino::Badge
        badge_or_code
      else
        Rewardino::Badge.find badge_or_code
      end

      revokable = badge.respond_to?(:revokable) and badge.revokable

      if evaluation_badge_condition(badge)
        if has_badge? badge.code
          Rewardino::StatusAlreadyAwarded.new
        else
          awarded_badge = AwardedBadge.create!(awardee_type: self.class.name,
            awardee_id: id, badge_code: badge.code)
          Rewardino::StatusAwarded.new badge.code
        end
      else
        if revokable and lost_badge = has_badge?(badge.code)
          lost_badge.destroy
          Rewardino::StatusTakenAway.new badge.code
        else
          Rewardino::StatusNotAwarded.new
        end
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
      def evaluation_badge_condition badge
        if badge.respond_to?(:condition) and badge.condition.present?
          badge.condition.call self
        else
          true
        end
      end

      def normalize_badge badge_or_code
      end
  end
end
