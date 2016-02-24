# encoding: utf-8

class DocumentUploader < BaseUploader
  def extension_white_list
  end

  def fog_attributes
    {
      'Content-Disposition' => 'attachment;',
      'Content-Type' => 'application/octet-stream',
    }
  end
end