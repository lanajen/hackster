class ParticipantInvite < ActiveRecord::Base
  belongs_to :issue
  belongs_to :project
  belongs_to :user

  attr_accessible :email, :project_id, :user_id, :issue_id, :accepted

  def self.find_by_auth_key auth_key
    auth_key.match /([0-9]+)-(.*)/
    record = find_by_id $1
    record if record and record.auth_key == auth_key
  end

  def auth_key
    "#{id}-#{Digest::SHA1.hexdigest("#{created_at.to_i + id * project_id * user_id}")}"
  end
end
