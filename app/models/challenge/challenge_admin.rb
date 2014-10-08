class ChallengeAdmin < ActiveRecord::Base
  include Roles

  belongs_to :challenge
  belongs_to :user

  set_roles :group_roles, %w(admin judge)
end