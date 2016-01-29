class University < GeographicCommunity
  has_many :courses, foreign_key: :parent_id, dependent: :destroy
end
