class ChallengeAdmin < ActiveRecord::Base
  include Roles

  belongs_to :challenge
  belongs_to :user

  attr_accessible :user_id

  set_roles :roles, %w(admin judge)
end