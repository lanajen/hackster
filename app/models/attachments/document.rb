class Document < Attachment
  mount_uploader :file, DocumentUploader

  def process
    if type == 'Document' and file_extension
      case file_extension
      when *ImageFile::IMAGE_EXTENSIONS
        update_attribute :type, 'ImageFile'

        queue_processing
        return

      when *PdfFile::PDF_EXTENSIONS
        update_attribute :type, 'PdfFile'

        queue_processing
        return

      when *SketchfabFile::SKETCHFAB_SUPPORTED_EXTENSIONS
        update_attribute :type, 'SketchfabFile'

        queue_processing
        return
      end
    end

    super
  end
end
