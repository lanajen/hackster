module Rewardino
  require 'ambry'
  require 'ambry/active_model'

  class Event
    extend Ambry::Model
    extend Ambry::ActiveModel

    MAX_REDEEMABLE_MONTHLY = 1000
    MIN_REDEEMABLE_POINTS = 350

    field :code, :points, :date_method, :models_method, :users_method,
      :user_method, :compute_method, :model_table, :name, :description,
      :boolean_method, :users_count_method

    validates_presence_of :code
    validates_uniqueness_of :code

    filters do
      def by_code code
        find { |e| e.code.to_s == code.to_s }
      end
    end

    class << self
      alias_method :find_key, :find

      def compute_for_user user_id, date=nil
        all.each do |event|
          event.compute_for_user user_id, date
        end
      end

      def find code
        find_key code.to_sym
      end

      def min_redeemable_points
        StoreProduct.cheapest.unit_cost || MIN_REDEEMABLE_POINTS
      end
    end

    def compute_for_user user_id, date=nil
      user = User.find_by_id user_id
      return unless user

      if compute_method
        compute_method.call(self, user, date)
      elsif !boolean_method or boolean_method.call(self, user)
        models = models_method.call(user)
        # models = models.where("#{model_table}.#{date_column} > ?", date) if date

        models.each do |model|

          event_date = date_method.call(model)
          next unless event_date

          users_count = users_count_method ? users_count_method.call(model) : 1

          prorated_points = users_count > 1 ? (points / users_count.to_f).ceil.to_i : points

          ReputationEvent.create event_name: code, event_model: model, points: prorated_points, event_date: event_date, user_id: user.id
        end
      end
    end
  end
end