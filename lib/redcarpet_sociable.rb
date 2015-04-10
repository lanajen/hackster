# module Redcarpet
#   class Socialable < Redcarpet::Render::HTML
    # autoload :Mentions, 'redcarpet/socialable/mentions'
    # autoload :Hashtags, 'redcarpet/socialable/hashtags'

    # include Mentions
    # include Hashtags


    # def paragraph(text)
    #   "<p>#{safe_replace(text)}</p>"
    # end

    # def list_item(text, list_type)
    #   "<li>#{safe_replace(text)}</li>"
    # end

    # def header(text, level)
    #   "<h#{level}>#{safe_replace(text)}</h#{level}>"
    # end

#   end
# end

module Redcarpet::Render::SociableHTML
  BASE_REGEXP =
    # If there's an HTML tag, catch it, we need this to exclude link tags
    '(<\/?[^>]*>)?' +
    # There should be a whitespace or beginning of line
    '(^|[\s\>])+' +
    # Placeholder for what we want to match
    '%s' +
    # This is where match ends
    '(\b|\-|\.|,|:|;|\?|!|\(|\)|$)?' +
    # Closing HTML tag if any
    '(<\/?[^>]*>)?'
      
  def postprocess(document)
    # Disable postprocess-ing for legacy renderer
    unless respond_to?(:safe_replace)
      document = process_hashtags(document)
    end

    if defined?(super)
      super(document)
    else
      document
    end
  end

  private

  def hashtag_template(text)
    # Some backwards compatibility
    if respond_to?(:tag_template)
      tag_template(text)
    else
      %(<a href="#/hashtags/#{text}" title="#{text}">##{text}</a>)
    end
  end

  def hashtag_regexp
    '#([\w\-]+)'
  end

  def hashtag?(matched_text)
    # Some backwards compatibility
    if respond_to?(:highlight_tag?)
      matched_text if highlight_tag?(matched_text)
    else
      matched_text
    end
  end

  def process_hashtags(text)
    # Find and render tags
    regexp = Regexp.new(::Redcarpet::Socialable::BASE_REGEXP % hashtag_regexp)

    text.gsub!(regexp) do |match|
      start_tag, before, raw, after, close_tag = $1, $2, $3, $4, $5
      return match if start_tag.to_s.start_with?('<a')

      if hashtag = hashtag?(raw)
        %{#{start_tag}#{before}#{hashtag_template(hashtag)}#{after}#{close_tag}}
      else
        match
      end
    end

    text
  end

  def safe_replace(text)
    text = process_mentions(text)
    process_hashtags(text)
  end
end