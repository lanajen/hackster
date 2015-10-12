class ChallengeIdeaField < Tableless
  belongs_to :challenge
  attr_accessible :label, :position, :required

  column :label, :string
  column :position, :integer
  column :required, :boolean
end