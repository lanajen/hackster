class FilesController < ApplicationController
  before_filter :authenticate_user!

  def create
    render text: 'bad', status: :unprocessable_entity and return unless params[:file_url] and params[:file_type] and params[:file_type].in? %w(avatar image cover_image document sketchfab_file logo)

    @file = params[:file_type].classify.constantize.new params.select{|k,v| k.in? %w(file caption title remote_file_url) }
    @file.attachable_id = params[:attachable_id] || 0
    @file.attachable_type = params[:attachable_type] || 'Orphan'
    @file.tmp_file = CGI.unescape params[:file_url]

    if @file.save
      render json: @file.attributes.merge(context: params[:context]), status: :ok
    else
      render json: @file.errors, status: :unprocessable_entity
    end
  end

  def show
    @file = Attachment.find params[:id]

    render json: @file.as_json(methods: :processed).to_hash.merge(context: params[:context]), status: :ok
  end

  def destroy
    @file = Attachment.find params[:id]
    @file.destroy

    render json: @file
  end

  def signed_url
    render json: {
      policy: s3_upload_policy_document,
      signature: s3_upload_signature,
      key: "uploads/tmp/#{SecureRandom.uuid}/#{params[:file][:name]}",
      success_action_redirect: "/",
      context: params[:context],
    }
  end

  private
    # generate the policy document that amazon is expecting.
    def s3_upload_policy_document
      Base64.encode64(
        {
          expiration: 30.minutes.from_now.utc.strftime('%Y-%m-%dT%H:%M:%S.000Z'),
          conditions: [
            { bucket: ENV['FOG_DIRECTORY'] },
            { acl: 'public-read' },
            ["starts-with", "$key", "uploads/"],
            { success_action_status: '201' }
          ]
        }.to_json
      ).gsub(/\n|\r/, '')
    end

    # sign our request by Base64 encoding the policy document.
    def s3_upload_signature
      Base64.encode64(
        OpenSSL::HMAC.digest(
          OpenSSL::Digest::Digest.new('sha1'),
          ENV['AWS_SECRET_ACCESS_KEY'],
          s3_upload_policy_document
        )
      ).gsub(/\n/, '')
    end
end