class DocumentWidget < Widget
  define_attributes [:documents_count]

  def self.model_name
    Widget.model_name
  end

  has_many :documents, as: :attachable

  attr_accessible :documents_attributes, :document_ids
  accepts_nested_attributes_for :documents, allow_destroy: true

  def to_tracker
    super.merge({
      documents_count: documents_count,
    })
  end
end
