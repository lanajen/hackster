class DocumentWidget < Widget
  has_many :documents, as: :attachable

  attr_accessible :documents_attributes
  accepts_nested_attributes_for :documents, allow_destroy: true

  def help_text
    "Add as many documents as you like."
  end
end
