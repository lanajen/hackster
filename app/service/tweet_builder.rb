class TweetBuilder
  MAX_SIZE = 140
  URL_SIZE = 23  # links are shortened to 22 characters, + 1 for space

  def initialize project
    @project = project
  end

  def tweet opts={}
    # we have 124-129 characters to play with

    message = opts[:prepend] || ''

    message << @project.name.gsub(/\.$/, '')

    message << generate_authors

    size = get_size(message, opts[:has_image])

    message << " #{url}"

    tags = @project.platforms.map do |platform|
      platform.twitter_hashtag.presence || TwitterHandle.new(platform.twitter_link).handle.presence || platform.hashtag
    end
    tags += @project.product_tags_cached.map{|t| "##{t.gsub(/[^a-zA-Z0-9]/, '')}"}

    if tags.any?
      tags.uniq!
      tags.each do |tag|
        new_size = size + tag.size + 1
        if new_size < MAX_SIZE
          message << " #{tag}"
          size += " #{tag}".size
        end
      end
    end

    message
  end

  private
    def generate_authors
      output = ''

      if @project.guest_name.present?
        output << " by #{@project.guest_name.strip}"
      elsif @project.team_members_count > 1
        if @project.team.name.present?
          output << " by #{@project.team.name.strip}"
        end
      else
        user = @project.users.first
        if user
          output << " by "
          handle = TwitterHandle.new(user.twitter_link).handle
          output << (handle.present? ? handle : user.name.strip)
        end
      end

      output
    end

    def get_size message, has_image=false
      urls_count = 1
      urls_count += 1 if has_image
      1 + message.size + (URL_SIZE * urls_count)
    end

    def url
      "hackster.io/#{@project.uri}"
    end
end