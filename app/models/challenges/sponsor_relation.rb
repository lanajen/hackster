class SponsorRelation < ActiveRecord::Base
  self.table_name = :challenges_groups

  belongs_to :challenge
  belongs_to :sponsor, class_name: 'Group', foreign_key: :group_id
end