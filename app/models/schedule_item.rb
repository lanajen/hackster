class ScheduleItem < Tableless
  belongs_to :event
  attr_accessible :parent_id, :position, :time, :description, :day

  column :position, :integer
  column :time, :string
  column :day, :string
  column :description, :text
  column :parent_id, :integer
end