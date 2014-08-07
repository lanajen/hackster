require 'open-uri'
SKETCHFAB_API_URL = 'https://api.sketchfab.com/v2'
SKETCHFAB_API_MODEL_ENDPOINT = SKETCHFAB_API_URL + '/models'
SKETCHFAB_API_TOKEN = 'f6f4db3865a945a38f0d09cae381efd6'

class SketchfabFile < Document

  def process
    super

    upload_to_sketchfab!
  end

  def processed?
    if tmp_file.present?
      false
    elsif uid.blank?
      'upload_pending'
    elsif uid == 'error'
      'upload_error'
    else
      'done'
    end
  end
  alias_method :processed, :processed?

  def uid
    title
  end

  def uid=(val)
    self.title = val
  end

  def uploaded_to_sketchfab?
    uid.present? and uid != 'error'
  end

  def upload_to_sketchfab!
    puts "hello"
    return unless (!uploaded_to_sketchfab? or file_changed?) and file = tmpfile

    puts "Uploading to sketchfab..."
    RestClient.post SKETCHFAB_API_MODEL_ENDPOINT,
      { 'modelFile' => file, 'token' => SKETCHFAB_API_TOKEN, name: file_name } do |json_response, request, result|

      response = JSON.parse json_response

      case result
      when Net::HTTPCreated
        update_attribute :uid, response['uid']
        return
      when Net::HTTPBadRequest
        puts "Error: #{response['detail']}"
      else
        puts "Unknown result: #{result.inspect} // response: #{response.inspect}"
      end
      update_attribute :uid, 'error'
    end
  end

  private
    def tmpfile
      file_contents = open(file_url).read
      ext = file_name.split('.').last
      file = Tempfile.new [file_name, ".#{ext}"], Rails.root.join('tmp'), :encoding => 'ascii-8bit'
      file.write file_contents
      file.rewind
      file
    rescue => e
      puts "Error reading file: #{e.inspect}"
    end
end