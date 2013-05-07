class AccessGroup < ActiveRecord::Base
  attr_accessible :name, :project_id
end
