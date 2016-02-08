class BaseArticleDecorator < ApplicationDecorator
  include MediumEditorDecorator
  include StoryJsonDecorator

  def cover_image version=:cover
    options = {}
    options[:fm] = 'jpg' if version == :cover  # force jpg so that gifs are not upscaled
    if model.cover_image
      if model.cover_image.file_url
        model.cover_image.imgix_url(version, options)
      elsif model.cover_image.tmp_file.present?
        h.asset_url "project_#{version}_image_processing.png"
      end
    else
      default_cover_image version
    end
  end

  def default_cover_image version=:thumb
    if h.is_whitelabel? and h.current_site.has_default_project_cover_image?
      h.asset_url h.current_site.default_project_cover_image_file_path
    else
      h.asset_url "project_default_#{version}_image.png"
    end
  end

  def difficulty
    BaseArticle::DIFFICULTIES.invert[model.difficulty.to_sym] if model.difficulty.present?
  end

  def duration
    return if model.duration.blank? or model.duration.zero?

    if model.duration < 1
      h.pluralize (model.duration * 60).floor, 'minute'
    elsif model.duration > 24
      _duration = model.duration / 24
      prefix = ''
      if _duration % 1 != 0
        prefix = 'Over '
      end
      prefix + h.pluralize(_duration.floor, 'day')
    else
      h.pluralize (model.duration % 1 == 0 ? model.duration.floor : model.duration), 'hour'
    end + ' to complete'
  end

  def description mode=:normal, options={}
    options = { mode: (mode || :normal) }.merge(options)
    parse_medium model.description, options
  end

  def story_json mode=:normal
    options = { mode: mode }
    return @story_json if @story_json

    @story_json = if model.story_json.present?
      parse_story_json model.story_json, options
    else
      ''
    end
  end

  def name_not_default
    model.name == BaseArticle::DEFAULT_NAME ? nil : model.name
  end

  def printable_description
    parse_medium model.description, { print: true }
  end

  def status
    out = model.publyc? ? 'Public' : 'Private'
    out + ' - ' + model.workflow_state.humanize
  end

  def to_personnal_message
    "I just published #{model.name} on hackster.io, take a look and tell me what you think!"
  end

  def to_share_message
    platforms = model.known_platforms
    sentences = ['I love this:', 'Check this out:', 'Cool stuff:', 'Awesome project:', 'Nice!']

    "#{sentences.sample} #{model.name} by #{model.guest_name.presence || model.users.map{|u| u.twitter_handle || u.name }.to_sentence}#{ ' with ' + platforms.map{|t| t.twitter_handle.presence || t.name }.to_sentence if platforms.any? }"
  end

  def to_personnal_tweet
    message = "I just published #{model.name} on @hacksterio, take a look and tell me what you think!"

    size = message.size + " http://#{APP_CONFIG['full_host']}/#{model.uri}".size

    model.known_platforms.map do |platform|
      if handle = platform.twitter_handle

        new_size = size + handle.size + 1
        if new_size <= 140
          message << " #{handle}"
          size += " #{handle}".size
        end
      end
    end

    # we add tags until character limit is reached
    tags = model.product_tags_cached.map{|t| "##{t.gsub(/[^a-zA-Z0-9]/, '')}"}
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
