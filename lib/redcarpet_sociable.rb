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
    document = process_hashtags(document)
    document = process_mentions(document)

    if defined?(super)
      super(document)
    else
      document
    end
  end

  private
    # mentions
    def mention_template user
      %(<a class="mention" data-user-name="#{user.user_name}" data-user-id="#{user.id}" href="/#{user.user_name}">#{user.full_name}</a>)
    end

    def mention_regexp
      '@([\w-]+)'
    end

    def process_mentions(text)
      regexp = Regexp.new(BASE_REGEXP % mention_regexp)

      text.gsub!(regexp) do |match|
        start_tag, before, mention, after, close_tag = $1, $2, $3, $4, $5
        return match if start_tag.to_s.start_with?('<a')

        if user = User.find_by_user_name(mention)
          %{#{start_tag}#{before}#{mention_template(user)}#{after}#{close_tag}}
        else
          match
        end
      end

      text
    end

    # hashtags
    def hashtag_template(text)
      %(<a href="#/hashtags/#{text}">##{text}</a>)
    end

    def hashtag_regexp
      '#([\w\-]+)'
    end

    def process_hashtags(text)
      # Find and render tags
      regexp = Regexp.new(BASE_REGEXP % hashtag_regexp)

      text.gsub!(regexp) do |match|
        start_tag, before, hashtag, after, close_tag = $1, $2, $3, $4, $5
        return match if start_tag.to_s.start_with?('<a')

        if hashtag
          %{#{start_tag}#{before}#{hashtag_template(hashtag)}#{after}#{close_tag}}
        else
          match
        end
      end

      text
    end
end