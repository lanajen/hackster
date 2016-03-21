class SketchfabWorker < BaseWorker
  sidekiq_options queue: :critical, retry: 1

  def upload file_id
    record = SketchfabFile.find file_id

    return if record.uploaded_to_sketchfab? or !(tmpfile = create_tmpfile(record))

    Rails.logger.debug "Uploading to sketchfab..."

    RestClient.post SKETCHFAB_API_MODEL_ENDPOINT,
      { 'modelFile' => tmpfile,
        'token' => SKETCHFAB_API_TOKEN,
        name: record.file_name,
        private: true } do |json_response, request, result|

      response = JSON.parse json_response

      case result
      when Net::HTTPCreated
        record.update_attribute :uid, response['uid']
        return
      when Net::HTTPBadRequest
        record.update_attribute :uid, 'error'
        raise "Error: #{response['detail']}"
      else
        record.update_attribute :uid, 'error'
        raise "Unknown result: #{result.inspect} // response: #{response.inspect}"
      end
    end
  end

  private
    def create_tmpfile record
      file_contents = open(record.file_url).read
      file = Tempfile.new [record.file_name, ".#{record.file_extension}"], Rails.root.join('tmp'), :encoding => 'ascii-8bit'
      file.write file_contents
      file.rewind
      file
    rescue => e
      puts "Error reading file: #{e.inspect}"
    end
end