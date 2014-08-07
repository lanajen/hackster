class OshparkEmbed < BaseEmbed
  BASE_URL = 'http://oshpark.com/shared_projects'
  BASE_UPLOADS_URL = 'http://uploads.oshpark.com/uploads/project'

  def bottom_image
    "#{BASE_UPLOADS_URL}/bottom_image/#{id}/i.png"
  end

  def bottom_image_thumb
    "#{BASE_UPLOADS_URL}/bottom_image/#{id}/thumb_i.png"
  end

  def download_link
    "#{BASE_UPLOADS_URL}/design/#{id}/design.brd"
  end

  def format
    'original'
  end

  def order_link
    "#{link}/order"
  end

  def top_image
    "#{BASE_UPLOADS_URL}/top_image/#{id}/i.png"
  end

  def top_image_thumb
    "#{BASE_UPLOADS_URL}/top_image/#{id}/thumb_i.png"
  end

  def link
    return @link if @link
    @link ||= "#{BASE_URL}/#{id}" if id.present?
    @link
  end
end