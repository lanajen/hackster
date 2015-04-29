class BaseMailer < ActionMailer::Base
  DEFAULT_EMAIL = 'Hackster.io<hi@hackster.io>'
  include SendGrid
  add_template_helper UrlHelper

  def deliver_email context, template, opts={}
    puts "#{Time.now.to_s} - Sending email '#{template}'."

    sendgrid_category template
    @context = context

    if context.include? :users
      return if context[:users].empty?
      context[:users] = context[:users].uniq
      users_copy = context[:users]
      users_copy.each_slice(1000) do |users|
        context[:users] = users
        send_bulk_email template
      end
    elsif context.include? :user
      send_single_email template, opts
    else
      send_notification_email template
    end
  end

  private
    def default_headers
      {
        from: @context[:from_email] || DEFAULT_EMAIL,
        reply_to: @context[:from_email] || DEFAULT_EMAIL,
      }
    end

    def default_host
      APP_CONFIG['full_host']
    end

    def get_value_for_token token, opts={}
      author = @context[:author] if @context.include? :author
      invite = @context[:invite] if @context.include? :invite
      issue = @context[:issue] if @context.include? :issue
      project = @context[:project] if @context.include? :project
      user = @context[:user] if @context.include? :user
      user = opts[:user] if opts.include? :user
      group = @context[:group] if @context.include? :group
      comment = @context[:comment] if @context.include? :comment

      token = token.gsub(/\|/, '')
      case token.to_sym
      when :author_link
        url.user_url(author, host: default_host)
      when :comment_body
        ActionView::Base.full_sanitizer.sanitize comment.body
      when :email_confirmation_link
        url.user_confirmation_url(confirmation_token: @context[:devise_token], host: default_host)
      when :group_link
        url.group_url(group, host: default_host)
      when :group_manage_members_link
        url.group_edit_members_url(group, host: default_host)
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
        url.issue_url(issue.threadable, issue, host: default_host)
      when :password_reset_link
        url.edit_user_password_url(reset_password_token: @context[:devise_token], host: default_host)
      when :project_link
        url.project_url(project, host: default_host)
      when :project_new_link
        url.new_project_url(project, host: default_host)
      when :project_edit_team_link
        url.project_edit_team_url(project, host: default_host)
      when :slogan
        SLOGAN
      when :unsubscribe_link
        return false unless defined?(user) and user
        url.edit_notifications_url(user_email: user.email,
          user_token: user.authentication_token, host: default_host)
      when :user_profile_edit_link
        url.profile_edit_url(host: default_host)
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

    # def newlines_to_html text
    #   paragraphs = text.split(/\r\n/)
    #   paragraphs.map { |p| p.present? ? "<p>#{p}</p>" : "<br>" }.join('')
    # end

    def send_notification_email type, opts={}
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

    def send_bulk_email type, opts={}
      @users = @context[:users]
      @headers = {
        to: DEFAULT_EMAIL,
      }
      send_email type
    end

    def send_email type, opts={}
      @context[:devise_token] = opts['token']
      @context[:personal_message] = opts['personal_message']
      subject = render template: "mailers/subjects/#{type}"
      body = render template: "mailers/bodies/#{type}.html", layout: 'email'
      premailer = Premailer.new(substitute_in(body), with_html_string: true,
        warn_level: Premailer::Warnings::SAFE)

      headers = {
        subject: substitute_in(subject),
      }.merge(@headers)

      if @users.present?
        sendgrid_recipients @users.map { |user| user.email }
        premailer.to_plain_text.scan(/\|[a-z_]*\|/).each do |token|
          substitutes = @users.map { |user| get_value_for_token(token, { user: user }) }
          sendgrid_substitute token, substitutes
        end
      end

      # raise premailer.to_inline_css.to_s

      output_email = mail(headers.merge(default_headers)) do |format|
        format.text { render text: premailer.to_plain_text }
        format.html { render text: premailer.to_inline_css }
      end

      LogLine.create(source: :mailer, log_type: :mail_sent,
        message: "Email sent of type: #{type} to #{(headers[:to])}")

      output_email
    end

    def substitute_in text
      text.scan(/\|[a-z_]*\|/).each do |token|
        if substitute = get_value_for_token(token)
          text = text.gsub(token, substitute.to_s) if substitute
        end
      end
      text
    end

    def url
      UrlGenerator.new
    end
end
