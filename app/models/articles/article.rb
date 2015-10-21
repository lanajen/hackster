class Article < BaseArticle
  PUBLIC_CONTENT_TYPES = {
    'Getting started guide' => :getting_started,
    'Protip' => :protip,
    'Teardown/Unboxing' => :teardown,
  }
  DEFAULT_CONTENT_TYPE = :protip
  CONTENT_TYPES_TO_HUMAN = PUBLIC_CONTENT_TYPES.invert

  is_impressionable counter_cache: true, unique: :session_hash

  add_checklist :parts, 'Products', 'parts.any?'
  add_checklist :description, 'Description', 'Sanitize.clean(description).try(:strip).present?'

  def self.model_name
    BaseArticle.model_name
  end

  def identifier
    'article'
  end
end