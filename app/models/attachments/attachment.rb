class Attachment < ActiveRecord::Base
  MAX_FILE_SIZE = 20  # MB

  attr_accessible :type, :file, :file_cache, :remote_file_url, :caption,
    :title, :position, :tmp_file

  belongs_to :attachable, polymorphic: true
  after_commit :queue_processing, on: :create, unless: proc{|a| a.processed? }
  after_commit :after_process, on: :create, if: proc{|a| a.processed? }

  def after_process
    notify_observers :after_process
  end

  def disallow_blank_file?
    @disallow_blank_file
  end

  def disallow_blank_file!
    @disallow_blank_file = true
  end

  def file_extension
    file_name.split('.').last
  end

  def file_name
    if file_url.present?
      File.basename file_url
    elsif tmp_file.present?
      File.basename tmp_file
    end
  end

  def needs_processing?
    send(:_mounter, :file).uploader.needs_processing?
  end

  def process
    return if processed?

    s3 = AWS::S3.new

    s3_tmp_file = tmp_file.split('/')[3..-1].join('/')
    name = s3_tmp_file.split('/').last
    file_path = "uploads/#{self.class.name.underscore}/file/#{id}/#{name}"
    s3.buckets[ENV['FOG_DIRECTORY']].objects[s3_tmp_file].move_to(file_path, acl: :public_read)

    raw_write_attribute :file, name
    file.recreate_versions! if needs_processing?  # only if has post processing

    update_attributes file: name, tmp_file: nil
  rescue AWS::S3::Errors::NoSuchKey
    destroy
  ensure
    notify_observers :after_process
  end

  def processed?
    tmp_file.blank?
  end
  alias_method :processed, :processed?  # so it can be used as json

  def queue_processing
    AttachmentQueue.perform_async 'process', id
  end

  def real_file_url
    if Rails.env == 'development' and ENV['CARRIERWAVE_FORCE_FOG'] != 'true'
      File.join(Rails.root, 'public', file_url)
    else
      file_url
    end
  end

  def skip_file_check?
    @skip_file_check
  end

  def skip_file_check!
    @skip_file_check = true
  end

  private
    def file_size
      errors[:file] << "should be less than #{MAX_FILE_SIZE}MB" if file.size > MAX_FILE_SIZE.megabytes
    end

    def strip_text text
      text.try(:strip)
    end
end
