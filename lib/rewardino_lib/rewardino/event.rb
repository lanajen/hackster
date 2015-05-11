module Rewardino
  require 'ambry'
  require 'ambry/active_model'

  class Event
    extend Ambry::Model
    extend Ambry::ActiveModel

    field :code, :points, :date_method, :models_method, :users_method,
      :user_method, :compute_method, :model_table, :name, :description

    validates_presence_of :code
    validates_uniqueness_of :code

    filters do
      def by_code code
        find { |e| e.code.to_s == code.to_s }
      end
    end

    class << self
      alias_method :find_key, :find

      def find code
        find_key code.to_sym
      end
    end

    def compute date=nil
      if compute_method
        compute_method.call(self, date)
      else
        models = eval(models_method)
        date_column = case date_method
        when Array
          date_method.first
        else
          date_method
        end
        models = models.where("#{model_table}.#{date_column} > ?", date) if date
        models.each do |model|
          users = if users_method
            users = model
            users_method.split('.').each do |method|
              users = users.send(method)
            end
            users
          elsif user_method
            user = model
            user_method.split('.').each do |method|
              user = user.send(method)
            end
            [user]
          else
            [model]
          end

          event_date = case date_method
          when Array
            result = nil
            date_method.each do |method|
              result = model.send(method)
              break if result.present?
            end
            result
          else
            model.send(date_method)
          end
          next unless event_date

          prorated_points = users.count > 1 ? (points / users.count.to_f).ceil.to_i : points
          users.each do |user|
            next unless user
            ReputationEvent.create event_name: code, event_model: model, points: prorated_points, event_date: event_date, user_id: user.id
          end
        end
      end
    end
  end
end