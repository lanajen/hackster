class Attachment < ActiveRecord::Base
  MAX_FILE_SIZE = 20  # MB

  attr_accessible :type, :file, :file_cache, :remote_file_url, :caption,
    :title, :position, :tmp_file
  # attr_accessor :skip_extension_check

  belongs_to :attachable, polymorphic: true
  # validate :ensure_has_file, unless: proc { |a| a.skip_file_check? }
  # validate :file_size
  after_commit :queue_processing, on: :create, unless: proc{|a| a.processed? }

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

    notify_observers :after_process
  end

  def processed?
    tmp_file.blank?
  end
  alias_method :processed, :processed?  # so it can be used as json

  def queue_processing
    AttachmentQueue.perform_async 'process', id
  end

  # def remote_file_url=(url)
  #   return if url.blank?

  #   return super(url) if File.extname(URI.parse(url).path).present?

  #   begin
  #     self.skip_extension_check = true
  #     file.download!(url)
  #   ensure
  #     self.skip_extension_check = false
  #   end

  #   path = file.path
  #   ext = File.extname(path)

  #   logger.debug "Downloaded file extension - #{ext}"

  #   if ext.blank? && ext = detect_extension(path)
  #     logger.debug "Detected extension for avatar - #{ext}"
  #     path = path + ".#{ext}"
  #     FileUtils.mv(file.path, path)
  #     file.remove!
  #     self.file = File.open(path)
  #   end

  #   file.send(:check_whitelist!, CarrierWave::SanitizedFile.new(File.open(path)))

  #   save!
  #   file.store!
  # end

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

  # protected
  #   def detect_extension(file_name)
  #     mime_type = %x(file --mime-type #{file_name}|cut -f2 -d' ').gsub("\n", "")
  #     case mime_type
  #     when 'image/jpeg'
  #       'jpg'
  #     when 'image/jpg'
  #       'jpg'
  #     when 'image/png'
  #       'png'
  #     when 'image/gif'
  #       'gif'
  #     end
  #   end
end
