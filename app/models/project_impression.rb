class ProjectImpression < ActiveRecord::Base
  belongs_to :project#, counter_cache: :impressions_count
  belongs_to :user
end
