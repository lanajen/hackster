class BaseArticleDecorator < ApplicationDecorator
  include MediumEditorDecorator

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
      h.asset_url "project_default_#{version}_image.png"
    end
  end

  def description mode=:normal, options={}
    options = { mode: (mode || :normal) }.merge(options)
    parse_medium model.description, options
  end

  def name_not_default
    model.name == BaseArticle::DEFAULT_NAME ? nil : model.name
  end

  def printable_description
    parse_medium model.description, { print: true }
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
