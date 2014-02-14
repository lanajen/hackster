class Promotion < Community
  belongs_to :course, foreign_key: :parent_id
end