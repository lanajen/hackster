class Session < ActiveRecord::SessionStore::Session
  belongs_to :user
  before_save :ensure_user_is_set, if: proc{|s| s.user_id.nil? }

  private
    def ensure_user_is_set
      warden_data = self.data["warden.user.user.key"]
      if warden_data
        user_id = warden_data[0][0]
        user = User.find_by_id user_id
        self.user = user if user
      end
    end
end