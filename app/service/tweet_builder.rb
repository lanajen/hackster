class TweetBuilder
  MAX_SIZE = 140
  URL_SIZE = 23  # links are shortened to 22 characters, + 1 for space

  def initialize project
    @project = project
  end

  def tweet prepend='', append=''
    # we have 113-118 characters to play with

    message = prepend

    message << @project.name.gsub(/\.$/, '')

    message << generate_authors

    size = get_size(message)

    message << " #{url}"

    tags = @project.platforms.map do |platform|
      TwitterHandle.new(platform.twitter_link).handle.presence || platform.hashtag
    end
    tags += @project.product_tags_cached.map{|t| "##{t.gsub(/[^a-zA-Z0-9]/, '')}"}

    if tags.any?
      tags.uniq!
      tags.each do |tag|
        new_size = size + tag.size + 1
        if new_size < MAX_SIZE
          message << " #{tag}"
          size += " #{tag}".size
        else
          break
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
        else
          output << " by #{@project.team_members_count} developers"
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

    def get_size message, url_included=false
      size = message.size + URL_SIZE
      size -= url.size - 1 if url_included
      size
    end

    def url
      "hackster.io/#{@project.uri}"
    end
end