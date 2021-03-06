# TODO: make it simpler/cleaner to use and move to V2
# 1. remove file_type => let attachable set the correct file type (eg, in cover_image_id=)
# 2. remove attachable_id and attachable_type. Instead set attachments from attachable itself (eg through cover_image_id= or images=)
# 3. leave only two accepted params: caption or title, and remote_file_url
# 4. allow for direct uploads...
class Api::PrivateDoorkeeper::FilesController < Api::PrivateDoorkeeper::BaseController
  before_filter :doorkeeper_autorize_user_wihtout_scope!, only: [:show, :destroy]

  def create
    render text: 'bad', status: :unprocessable_entity and return unless params[:file_url] and params[:file_type] and params[:file_type].in? %w(avatar image cover_image document sketchfab_file logo company_logo favicon alternate_cover_image)

    @file = params[:file_type].classify.constantize.new params.select{|k,v| k.in? %w(file caption title remote_file_url) }
    @file.attachable_id = params[:attachable_id] || 0
    @file.attachable_type = params[:attachable_type] || 'Orphan'
    @file.tmp_file = CGI.unescape params[:file_url]

    if @file.save
      render json: @file.attributes.merge(file_name: @file.file_name).merge(context: params[:context]), status: :ok
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

  def remote_upload
    render text: 'bad', status: :unprocessable_entity and return unless params[:file_url] and params[:file_type] and params[:file_type].in? %w(avatar image cover_image document sketchfab_file logo company_logo favicon alternate_cover_image) and valid_url?(params[:file_url])

    @file = params[:file_type].classify.constantize.new params.select{|k,v| k.in? %w(file caption title remote_file_url) }
    @file.attachable_id = params[:attachable_id] || 0
    @file.attachable_type = params[:attachable_type] || 'Orphan'

    if @file.save
      job_id = AttachmentQueue.perform_async 'remote_upload', @file.id, params[:file_url]
      render json: @file.attributes.merge(context: params[:context], job_id: job_id), status: :ok
    else
      render json: @file.errors, status: :unprocessable_entity
    end
  end

  def check_remote_upload
    job_id = params[:job_id]
    render json: { status: Sidekiq::Status::status(job_id) }
  end

  def signed_url
    render nothing: true, status: :unprocessable_entity and return unless params[:file]

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

    def valid_url? url
      url =~ /\A#{URI::regexp(['http', 'https'])}\z/
    end
end