class TweetBuilder
  def initialize project
    @project = project
  end

  def tweet prepend='', append=''
    # we have 113-118 characters to play with

    message = prepend

    message << @project.name.gsub(/\.$/, '')

    if @project.guest_name.present?
      message << " by #{@project.guest_name}"
    elsif @project.team_members_count > 1
      if @project.team.name.present?
        message << " by #{@project.team.name}"
      else
        message << " by #{@project.team_members_count} developers"
      end
    else
      user = @project.users.first
      if user
        message << " by #{user.name}"
        if link = user.twitter_link.presence and handle = link.match(/twitter.com\/([a-zA-Z0-9_]+)/).try(:[], 1)
          message << " (@#{handle})"
        end
      end
    end

    size = message.size + 23

    tags = @project.platforms.map do |platform|
      out = platform.hashtag
      if link = platform.twitter_link.presence and handle = link.match(/twitter.com\/([a-zA-Z0-9_]+)/).try(:[], 1)
        out << " (@#{handle})"
      end
      out
    end
    if tags.any?
      tag_phrase = " with #{tags.to_sentence}"
      message << tag_phrase if (size + tag_phrase.size) <= 140
      size = message.size + 23
    end

    message << " hackster.io/#{@project.uri}"  # links are shortened to 22 characters

    # we add tags until character limit is reached
    tags = @project.product_tags_cached.map{|t| "##{t.gsub(/[^a-zA-Z0-9]/, '')}"}
    if tags.any?
      tags.each do |tag|
        new_size = size + tag.size + 1
        if new_size <= 140
          message << " #{tag}"
          size += " #{tag}".size
        else
          break
        end
      end
    end

    message
  end
end