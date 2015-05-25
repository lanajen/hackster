class PartRelation < ActiveRecord::Base
  belongs_to :child_part, class_name: 'Part'
  belongs_to :parent_part, class_name: 'Part'
end