class StlWidget < Widget
  define_attributes [:sketchfab_uid]

  def self.model_name
    Widget.model_name
  end

  has_many :documents, as: :attachable
  has_many :sketchfab_files, as: :attachable

  attr_accessible :documents_attributes, :document_ids,
    :sketchfab_files_attributes, :sketchfab_file_ids
  accepts_nested_attributes_for :documents, :sketchfab_files, allow_destroy: true

  def embed_format
    'widescreen'
  end
end