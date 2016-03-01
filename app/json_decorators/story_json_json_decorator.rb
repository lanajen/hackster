class StoryJsonJsonDecorator
  attr_accessor :story_json

  def initialize story_json
    @story_json = story_json
  end

  def to_json
    _story_json = story_json.map do |c|
      if c['type'] == 'Carousel'
        ids = c['images'].map{|i| i['id'] }
        images = Image.where(id: ids)

        images.each do |image|
          c['images'] = c['images'].each_with_index do |img, i|
            if image.id.to_s == img['id'].to_s
              c['images'][i]['url'] = image.decorate.file_url(:headline)
            end
          end
        end

        c['images'].select!{ |img| img['url'].present? }

        c
      elsif c['type'] == 'File'
        c['data']['url'] = Attachment.find(c['data']['id']).file_url
        c
      else
        c
      end
    end

    _story_json
  end
end