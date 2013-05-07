class DocumentWidget < Widget

  def self.model_name
    Widget.model_name
  end
  
  has_many :documents, as: :attachable

  attr_accessible :documents_attributes
  accepts_nested_attributes_for :documents, allow_destroy: true

  def help_text
    "Add as many documents as you like."
  end
end
