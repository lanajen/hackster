class StlWidget < Widget

  def self.model_name
    Widget.model_name
  end
  
  has_many :documents, as: :attachable

  attr_accessible :documents_attributes
  accepts_nested_attributes_for :documents, allow_destroy: true

  def help_text
    "Add your STL file and we'll do the rest"
  end
end