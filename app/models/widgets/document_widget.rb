class DocumentWidget < Widget
  define_attributes [:documents_count]

  def self.model_name
    Widget.model_name
  end

  has_many :documents, as: :attachable

  attr_accessible :documents_attributes, :document_ids
  accepts_nested_attributes_for :documents, allow_destroy: true

  def to_text
    output = documents.map do |d|
      "<div contenteditable='false' class='embed-frame' data-type='file' data-file-id='#{d.id}' data-caption='#{d.title || d.file_name}'></div>"
    end.join('')
    "<h3>#{name}</h3>#{output}"
  end

  def to_tracker
    super.merge({
      documents_count: documents_count,
    })
  end
end
