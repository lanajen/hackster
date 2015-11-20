class ExternalProject < BaseProject
  PUBLIC_CONTENT_TYPES = {
    'Link to third party website' => :external,
  }
  CONTENT_TYPES_TO_HUMAN = {
    external: 'External link',
  }

  validates :name, :website, :one_liner, :cover_image, presence: true
  before_save :ensure_is_hidden

  is_impressionable counter_cache: true, unique: :session_hash

  before_save :set_content_type, if: proc{|p| p.content_type.blank? }

  def self.model_name
    BaseArticle.model_name
  end

  def content_type_to_human
    'External link'
  end

  def ensure_is_hidden
    self.hide = true
  end

  def identifier
    'link'
  end

  protected
    def set_content_type
      self.content_type = :external
    end
end
