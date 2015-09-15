module ActiveRecordExtension
  extend ActiveSupport::Concern

  module ClassMethods
    def median(column_name)
      median_index = (count / 2)
      # order by the given column and pluck out the value exactly halfway
      order(column_name).offset(median_index).limit(1).pluck(column_name)[0]
    end
  end
end

# include the extension
ActiveRecord::Base.send(:include, ActiveRecordExtension)