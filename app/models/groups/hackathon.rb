class Hackathon < Community
  has_many :events, foreign_key: :parent_id
end