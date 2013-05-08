class PrivacyRule < ActiveRecord::Base
  belongs_to :privatable, polymorphic: true
  belongs_to :privatable_user, polymorphic: true

  attr_accessible :privatable_id, :privatable_type, :privatable_user_id, :privatable_user_type, :private
end
