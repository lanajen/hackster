class Step < Tableless
  belongs_to :widget
  attr_accessible :details, :widget_id, :title, :position

  column :position, :integer
  column :title, :string
  column :details, :text
  column :widget_id, :integer
end