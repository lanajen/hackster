class StoreProductAction
  attr_accessor :url, :followable, :type, :message

  def completed_by? user
    case @type
    when 'follow'
      user.following? @followable
    when 'newsletter_url', 'signup'
      false
    end
  end

  def initialize options={}
    @type = options.delete('type')
    case type
    when 'follow'
      @followable = options['followable_type'].constantize.find(options['followable_id'])
    when 'newsletter_url', 'signup'
      @url = options['url']
    end
    @message = options['message']
  end

  def to_s
    case type
    when 'follow'
      "Follow #{@followable.name}"
    when 'newsletter_url'
      "Signup for their newsletter at #{@url}"
    when 'signup'
      "Register for an account on #{@url}"
    end
  end
end