class Team < Group
  has_many :projects
  attr_accessible :members_attributes
  accepts_nested_attributes_for :members, allow_destroy: true
end