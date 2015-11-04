class ChallengeIdeaField < Tableless
  belongs_to :challenge
  attr_accessible :label, :position, :required, :hide

  column :label, :string
  column :position, :integer
  column :required, :boolean
  column :hide, :boolean
end