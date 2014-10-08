class Video < ActiveRecord::Base

  belongs_to :recordable, polymorphic: true
  attr_accessible :link
  attr_accessor :not_found
  before_validation :get_info_from_provider
  validate :exists
#  validates :project_id, presence: true
  validates :link, length: { maximum: 255 }

  # height and width deprecated, now only storing ratio so that template can
  # decide on actual sizes
  # DEFAULT_HEIGHT = 480
  DEFAULT_RATIOS = {
    instagram: {
     width: 306,
     height: 355,
    },
    ustream: {
     width: 120,
     height: 77,
    },
    vimeo: {
     width: 16,
     height: 9,
    },
    vine: {
     width: 1,
     height: 1,
    },
    youtube: {
     width: 4,
     height: 3,
    },
  }
  # FIXED_WIDTH = 640
  KNOWN_PROVIDERS = {
    /instagram\.com/ => :instagram,
    /ustream\.tv/ => :ustream,
    /vimeo\.com/ => :vimeo,
    /vine\.co/ => :vine,
    /youtu(\.be|be\.com)/ => :youtube,
  }

  def get_info_from_provider
    destroy and return if link.blank?  # the model should not be persisted if there's no link
    return unless link_changed?  # only do this if there's a new link

    KNOWN_PROVIDERS.each do |regex, provider|
      self.provider = provider
      self.ratio_width = DEFAULT_RATIOS[provider][:width]
      self.ratio_height = DEFAULT_RATIOS[provider][:height]
      return send("get_info_from_#{provider}") if link =~ regex
    end

    # if we get there then there was no match and we throw an error
    providers_list = (KNOWN_PROVIDERS.values.uniq.map { |prov| prov.capitalize }).to_sentence
    errors[:link] << I18n.translate('activerecord.errors.models.video.provider_not_supported', providers_list: providers_list)
    false
  end

  private
    def exists
      errors[:base] << I18n.translate('activerecord.errors.models.video.not_found') if not_found
    end

    # def get_height_from_ratio height, width
    #   (height * (FIXED_WIDTH.to_f / width.to_f)).to_i
    # end

    def get_info_from_instagram
      self.id_for_provider = link[/instagram\.com\/p\/([a-zA-Z]+)/,1]
    end

    def get_info_from_ustream
      self.id_for_provider = link[/ustream\.tv\/([a-z]+\/[0-9]+(\/[a-z]+\/[0-9]+)?)/,1]
    end

    def get_info_from_vimeo
      self.id_for_provider = link[/vimeo\.com\/([0-9]+)/,1]
      parsed_response = Vimeo::Simple::Video.info(id_for_provider).parsed_response
      unless parsed_response.kind_of? Array # if video doesn't exist
        self.not_found = true
        return
      end
      video_info = parsed_response[0]
      self.title = video_info['title']
      self.ratio_width, self.ratio_height = get_ratio_from_dimensions video_info['width'], video_info['height']
      self.thumbnail_link = video_info['thumbnail_large']
    rescue => e
      case e.class.to_s
      when 'SocketError'
        errors.add :base, I18n.translate('activerecord.errors.models.video.vimeo_communication')
      else
        raise e
      end
    end

    def get_info_from_vine
      self.id_for_provider = link[/vine\.co\/v\/([a-zA-Z0-9]+)/,1]
    end

    def get_info_from_youtube
      self.id_for_provider = get_id_from_link_for_youtube link
    end

    def get_ratio_from_dimensions width, height
      ratio = Rational width, height
      return ratio.numerator, ratio.denominator
    end

    def get_id_from_link_for_youtube link
      case link
      when /embed\//
        #http://www.youtube.com/embed/wf_IIbT8HGk
        return link.split('embed/')[1].split('?')[0]
      when /youtu.be\//
        #http://youtu.be/wf_IIbT8HGk
        return link.split('youtu.be/')[1]
      when /\/v\//
        #http://www.youtube.com/v/Gladg-WY4yo&fs=1&start=
        return link.split('/v/')[1].split('&')[0]
      when /\?/
        #http://www.youtube.com/watch?v=wf_IIbT8HGk
        params = link.split('?')[1]
        params.split('&').each do |param|
          return param.split('=')[1] if param.split('=')[0] == 'v'
        end
      end
      self.link = nil
    end
end