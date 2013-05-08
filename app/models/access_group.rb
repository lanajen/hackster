class AccessGroup < ActiveRecord::Base
  belongs_to :project
  has_many :access_group_members, dependent: :destroy
  has_many :privacy_rules, as: :privatable_users

  accepts_nested_attributes_for :access_group_members, allow_destroy: true
  attr_accessible :name, :access_group_members_attributes
end
