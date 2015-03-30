class FileWidget < Widget
  define_attributes [:comment]

  has_one :document, as: :attachable, class_name: 'Document'

  attr_accessible :document_attributes, :document_id
  accepts_nested_attributes_for :document, allow_destroy: true

  validate :ensure_document_id

  def self.model_name
    Widget.model_name
  end

  def document_id
    document.try(:id)
  end

  def document_file_name
    document.try(:file_name)
  end

  def document_id=(val)
    self.document = Document.find_by_id val
  end

  def identifier
    # case document.try(:type)
    # when 'ImageFile'
    #   'image_file_widget'
    # when 'SketchfabFile'
    #   'sketchfab_widget'
    # else
      'file_widget'
    # end
  end

  def name
    read_attribute(:name).presence || document.try(:file_name) || 'Untitled file'
  end

  private
    def ensure_document_id
      errors.add :document_id, 'is required' unless document_id
    end
end