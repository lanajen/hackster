# encoding: utf-8

class DocumentUploader < BaseUploader
  def extension_white_list
    %w(jpg jpeg gif png js css eot woff svg ttf ico)
  end
end
