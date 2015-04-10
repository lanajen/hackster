class Channel < ActiveRecord::Base
  include Counter

  belongs_to :group
  has_and_belongs_to_many :hashtags
  has_many :thoughts, through: :hashtags

  attr_accessible :name, :restricted
end
