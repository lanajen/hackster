class ChallengeCategory < ActiveRecord::Base
  belongs_to :challenge
  has_many :entries, class_name: 'ChallengeEntry'
end
