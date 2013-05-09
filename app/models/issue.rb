class Issue < ThreadPost
  include Workflow
  
  has_many :participant_invites

  workflow do
    state :unresolved do
      event :resolve, transitions_to: :resolved
    end
    state :resolved do
      event :reopen, transitions_to: :unresolved
    end
  end
end
