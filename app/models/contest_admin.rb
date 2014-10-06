class ContestAdmin < ActiveRecord::Base
  include Roles

  belongs_to :contest
  belongs_to :user

  set_roles :group_roles, %w(admin judge)
end