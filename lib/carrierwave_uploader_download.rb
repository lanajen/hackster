# encoding: utf-8

require 'open-uri'

module CarrierWave
  module Uploader
    module Download
      extend ActiveSupport::Concern

      #extend download method so that the current model is passed to RemoteFile class
      def download!(uri)
        processed_uri = process_uri(uri)
        file = RemoteFile.new(processed_uri, model)
        raise CarrierWave::DownloadError, "trying to download a file which is not served over HTTP" unless file.http?
        cache!(file)
      end

      class RemoteFile
        include CarrierWave::Uploader::Mountable

        def initialize(uri, model=nil) #cache passed model in instance variable
          @uri = uri
          @model = model
        end
        def file
          if @file.blank?
            #construct channel for redis by filename
            @file_channel = "remote_download:#{@uri.to_s.split('/').last.gsub(/([a-zA-Z0-9]+)\..*/, '\1')}"
            @file = Kernel.open(@uri.to_s,
              progress_proc: update_progress,
              content_length_proc: update_content_length
            )
            @file = @file.is_a?(String) ? StringIO.new(@file) : @file
          end
          @file

        rescue Exception => e
          raise CarrierWave::DownloadError, "could not download file: #{e.message}"
        end

        # inject the file_channel into the procs or stub out the proc so the callback can call a Proc without any exceptions

        def update_progress
          if @model && defined?(@model.remote_progress_proc) #only exec if this method is defined
            @model.remote_progress_proc(@file_channel)
          else
            Proc.new {}
          end
        end
        def update_content_length
          if @model && defined?(@model.remote_content_length_proc)
            @model.remote_content_length_proc(@file_channel)
          else
            Proc.new {}
          end

        end
      end
    end
  end
end