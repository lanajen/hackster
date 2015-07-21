class StoreProductAction
  attr_accessor :url, :followable, :type

  def completed_by? user
    case @type
    when 'follow'
      user.following? @followable
    when 'signup'
      false
    end
  end

  def initialize options={}
    @type = options.delete('type')
    case type
    when 'follow'
      @followable = options['followable_type'].constantize.find(options['followable_id'])
    when 'signup'
      @url = options['url']
    end
  end

  def to_s
    case type
    when 'follow'
      "Follow #{@followable.name}"
    when 'signup'
      "Register for an account on #{@url}"
    when 'newsletter_url'
      "Signup for their newsletter at #{@url}"
    end
  end
end