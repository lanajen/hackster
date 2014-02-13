class Attachment < ActiveRecord::Base
  MAX_FILE_SIZE = 20  # MB

  attr_accessible :type, :file, :file_cache, :remote_file_url, :caption,
    :title, :position, :tmp_file

  belongs_to :attachable, polymorphic: true
  # validate :ensure_has_file, unless: proc { |a| a.skip_file_check? }
  # validate :file_size
  after_save :queue_processing, unless: proc{|a| a.processed? }

  def disallow_blank_file?
    @disallow_blank_file
  end

  def disallow_blank_file!
    @disallow_blank_file = true
  end

  def needs_processing?
    send(:_mounter, :file).uploader.needs_processing?
  end

  def process
    return if processed?

    s3 = AWS::S3.new

    s3_tmp_file = tmp_file.split('/')[3..-1].join('/')
    file_name = s3_tmp_file.split('/').last
    file_path = "uploads/#{self.class.name.underscore}/file/#{id}/#{file_name}"
    s3.buckets[ENV['FOG_DIRECTORY']].objects[s3_tmp_file].move_to(file_path, acl: :public_read)

    raw_write_attribute :file, file_name
    file.recreate_versions! if needs_processing?  # only if has post processing

    update_attributes file: file_name, tmp_file: nil
  end

  def processed?
    tmp_file.blank?
  end
  alias_method :processed, :processed?  # so it can be used as json

  def queue_processing
    Resque.enqueue AttachmentQueue, 'process', id
  end

  def skip_file_check?
    @skip_file_check
  end

  def skip_file_check!
    @skip_file_check = true
  end

  private
    def ensure_has_file
      unless disallow_blank_file?
        destroy
      else
        errors.add :file, "can't be blank"
      end if file.blank? and file_url.blank? and remote_file_url.blank?
    end

    def file_size
      errors[:file] << "should be less than #{MAX_FILE_SIZE}MB" if file.size > MAX_FILE_SIZE.megabytes
    end
end
