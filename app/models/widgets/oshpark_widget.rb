class OshparkWidget < Widget
  BASE_URL = 'http://oshpark.com/shared_projects'
  BASE_UPLOADS_URL = 'http://uploads.oshpark.com/uploads/project'

  define_attributes [:osh_id]
  attr_accessor :link
  attr_accessible :link
  validates :link, format: { with: /oshpark\.com\/shared_projects\/[a-zA-Z0-9]+/, message: "isn't a recognized link to a shared project on OSH Park"}, if: proc { |w| w.persisted? }
  before_save :extract_osh_id_from_link

  def self.model_name
    Widget.model_name
  end

  def bottom_image
    "#{BASE_UPLOADS_URL}/bottom_image/#{osh_id}/i.png"
  end

  def bottom_image_thumb
    "#{BASE_UPLOADS_URL}/bottom_image/#{osh_id}/thumb_i.png"
  end

  def default_label
    'PCB renderings'
  end

  def download_link
    "#{BASE_UPLOADS_URL}/design/#{osh_id}/design.brd"
  end

  def link
    return @link if @link
    @link ||= "#{BASE_URL}/#{osh_id}" if osh_id.present?
    @link
  end

  def order_link
    "#{link}/order"
  end

  def top_image
    "#{BASE_UPLOADS_URL}/top_image/#{osh_id}/i.png"
  end

  def top_image_thumb
    "#{BASE_UPLOADS_URL}/top_image/#{osh_id}/thumb_i.png"
  end

  def to_text
    "<h3>#{name}</h3><div contenteditable='false' class='embed-frame' data-type='url' data-url='#{link}' data-caption=''></div>"
  end

  private
    def extract_osh_id_from_link
      return if link.blank?
      #http://oshpark.com/shared_projects/5Dyth6rT

      self.osh_id = link.match(/oshpark\.com\/shared_projects\/([a-zA-Z0-9]+)/)[1]
    end
end
