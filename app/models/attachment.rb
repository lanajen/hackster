class Attachment < ActiveRecord::Base
  attr_accessible :type, :file, :file_cache, :remote_file_url, :caption, :title

  belongs_to :attachable, polymorphic: true
  validate :ensure_has_file, unless: proc { |a| a.skip_file_check? }

  def disallow_blank_file?
    @disallow_blank_file
  end

  def disallow_blank_file!
    @disallow_blank_file = true
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
        errors.add :file, 'cannot be blank'
      end if file.blank? and remote_file_url.blank?
    end
end
