require 'open-uri'

class SketchfabFile < Document

  def process
    super

    SketchfabWorker.perform_async 'upload', id
  end

  def processed?
    if tmp_file.present?
      false
    elsif uid.blank?
      'upload_pending'
    elsif uid == 'error'
      'upload_error'
    else
      'done'
    end
  end
  alias_method :processed, :processed?

  def uid
    title
  end

  def uid=(val)
    self.title = val
  end

  def uploaded_to_sketchfab?
    uid.present? and uid != 'error'
  end
end