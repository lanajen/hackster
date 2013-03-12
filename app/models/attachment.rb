class Attachment < ActiveRecord::Base
  attr_accessible :type, :file, :file_cache, :remote_file_url

  belongs_to :attachable, polymorphic: true
  before_validation :ensure_has_file, unless: proc { |a| a.skip_file_check? }

  def skip_file_check?
    @skip_file_check
  end

  def skip_file_check!
    @skip_file_check = true
  end

  private
    def ensure_has_file
      destroy if file.nil? or file.blank?
    end
end
