module MailerHelpers
  extend ActionView::Helpers::UrlHelper

  DEFAULT_EMAIL = 'Hackster.io<team@hackster.io>'

  def send_notification_email type
    @headers = {
      to: DEFAULT_EMAIL,
    }
    send_email type
  end

  def send_single_email type, opts={}
    @user = @context[:user]
    @headers = {
      to: @user.email,
    }
    send_email type, opts
  end

  def send_bulk_email type
    @users = @context[:users]
    @headers = {
      to: DEFAULT_EMAIL,
    }
    send_email type
  end

  def send_email type, opts={}
    email = Email.find_by_type(type)
    if email.nil?
      self.message.perform_deliveries = false
      msg = "Email was not sent because template '#{type}' doesn't exist."
      LogLine.create(source: :mailer, log_type: :mail_delivery_failed,
        message: msg)
      return
    end
    @context[:devise_token] = opts['token']
    premailer = Premailer.new(substitute_in(email.body), with_html_string: true,
      warn_level: Premailer::Warnings::SAFE)

    headers = {
      subject: substitute_in(email.subject),
    }.merge(@headers)

    if @users.present?
      sendgrid_recipients @users.map { |user| user.email }
      premailer.to_plain_text.scan(/\|[a-z_]*\|/).each do |token|
        substitutes = @users.map { |user| get_value_for_token(token, { user: user }) }
        sendgrid_substitute token, substitutes
      end
    end

    output_email = mail(headers.merge(default_headers)) do |format|
      format.text { render text: premailer.to_plain_text }
      format.html { render text: premailer.to_inline_css }
    end

    LogLine.create(source: :mailer, log_type: :mail_sent,
      message: "Email sent of type: #{type}")

    # Output any CSS warnings
    premailer.warnings.each do |w|
      msg = "#{w[:message]} (#{w[:level]}) may not render properly in #{w[:clients]}"
      LogLine.create(source: :mailer, log_type: :mail_css_warning,
        message: msg)
    end
    output_email
  end

  private
    def default_headers
      {
        from: DEFAULT_EMAIL,
        reply_to: DEFAULT_EMAIL,
      }
    end

    def default_host
      APP_CONFIG['full_host']
    end

    def get_value_for_token token
      invite = @context[:invite] if @context.include? :invite
      issue = @context[:issue] if @context.include? :issue
      project = @context[:project] if @context.include? :project
      user = @context[:user] if @context.include? :user
      group = @context[:group] if @context.include? :group

      token = token.gsub(/\|/, '')
      case token.to_sym
      when :email_confirmation_link
        url.user_confirmation_url(confirmation_token: @context[:devise_token], host: default_host)
      when :group_invitation_link
        url.group_accept_invitation_url(group, host: default_host)
      when :invite_friends_link
        url.new_user_invitation_url(host: default_host)
      when :invite_edit_url
        url.edit_invite_request_url(invite, host: default_host)
      when :invite_project_url
        url.project_url(invite.project, host: default_host) if invite.project
      when :invited_profile_link
        url.user_url(@context[:invited], host: default_host)
      # when :inviter_name
      #   user.invited_by.name
      when :invitation_link
        url.accept_user_invitation_url(invitation_token: user.invitation_token, host: default_host)
      when :issue_link
        url.issue_url(issue, host: default_host)
      when :password_reset_link
        url.edit_user_password_url(reset_password_token: @context[:devise_token], host: default_host)
      when :project_link
        url.project_url(project, host: default_host)
      when :project_new_link
        url.new_project_url(project, host: default_host)
      when :slogan
        SLOGAN
      when :user_profile_edit_link
        url.user_url(user, host: default_host)
      else
        split_token = token.split '_', 2
        object = split_token[0]
        attribute = split_token[1]
        if @context.include? object.to_sym and @context[object.to_sym].respond_to? attribute
          @context[object.to_sym].send(attribute).to_s
        else
          msg = "Called for unknown token: #{token}."
          LogLine.create(source: :mailer, log_type: :unknown_token,
            message: msg)
          return token
        end
      end
    end

    def newlines_to_html text
      paragraphs = text.split(/\r\n/)
      paragraphs.map { |p| p.present? ? "<p>#{p}</p>" : "<br>" }.join('')
    end

    def substitute_in text
      text.scan(/\|[a-z_]*\|/).each do |token|
        if substitute = get_value_for_token(token)
          text = text.gsub(token, substitute.to_s)
        end
      end
      text
    end

    def url
      UrlGenerator.new
    end
end
