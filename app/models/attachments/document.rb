class Document < Attachment
  mount_uploader :file, DocumentUploader

  def self.save_from_file file
    doc = new

    doc.file.cache! file
    doc.save
    doc
  end

  def process
    if type == 'Document' and file_extension
      case file_extension.downcase
      when *IMAGE_EXTENSIONS
        update_attribute :type, 'ImageFile'

        queue_processing
        return

      when *PDF_EXTENSIONS
        update_attribute :type, 'PdfFile'

        queue_processing
        return

      when *SKETCHFAB_SUPPORTED_EXTENSIONS
        update_attribute :type, 'SketchfabFile'

        queue_processing
        return
      end
    end

    super
  end
end
