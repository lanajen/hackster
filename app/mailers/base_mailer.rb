class BaseMailer < ActionMailer::Base
  ADMIN_EMAIL = 'Ben<ben@hackster.io>'
  DEFAULT_EMAIL = 'Hackster.io<hi@hackster.io>'
  add_template_helper ApplicationHelper
  add_template_helper UrlHelper

  def deliver_email context, template, opts={}
    puts "#{Time.now.to_s} - Sending email '#{template}'."

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
        reply_to: @context[:reply_to].presence || @context[:from_email] || DEFAULT_EMAIL,
      }
    end

    def extract_emails users
      users.map { |user| user.email }
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

      token = token.gsub(/\|/, '').gsub(/\*/, '')
      case token.to_sym
      when :author_link
        url.user_url(author)
      when :comment_body
        ActionView::Base.full_sanitizer.sanitize comment.body
      when :email_confirmation_link
        url.user_confirmation_url(confirmation_token: @context[:devise_token])
      when :group_link
        url.group_url(group)
      when :group_manage_members_link
        url.group_edit_members_url(group)
      when :group_invitation_link
        url.group_accept_invitation_url(group)
      when :invitation_link
        url.accept_user_invitation_url(invitation_token: user.invitation_token)
      when :issue_link
        url.issue_url(issue.threadable, issue)
      when :password_reset_link
        url.edit_user_password_url(reset_password_token: @context[:devise_token])
      when :project_link
        url.project_url(project)
      when :project_new_link
        url.new_project_url(project)
      when :project_edit_team_link
        url.project_edit_team_url(project)
      when :slogan
        SLOGAN
      when :update_preferences_link
        return false unless defined?(user) and user
        url.edit_notifications_url(user_email: user.email,
          user_token: user.authentication_token)
      when :user_profile_edit_link
        url.profile_edit_url
      else
        return unless token.present?
        if token =~ /\Aunsubscribe_link/
          return false unless defined?(user) and user
          unsubscribe_token = token.split(/:/)[1]
          url.unsubscribe_url(user, unsubscribe: unsubscribe_token)
        elsif token =~ /\Achange_frequency_link/
          return false unless defined?(user) and user
          frequency = token.split(/:/)[1]
          url.change_frequency_url(user, frequency: frequency)
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
    end

    # def newlines_to_html text
    #   paragraphs = text.split(/\r\n/)
    #   paragraphs.map { |p| p.present? ? "<p>#{p}</p>" : "<br>" }.join('')
    # end

    def send_notification_email type, opts={}
      @headers = {
        to: ADMIN_EMAIL,
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
        to: extract_emails(@users),
      }
      send_email type
    end

    def send_email type, opts={}
      @context[:devise_token] = opts['token']
      @context[:personal_message] = opts['personal_message']
      layout = type == 'new_projects' ? 'nicer_email' : 'email'
      subject = render template: "mailers/subjects/#{type}"
      body = render template: "mailers/bodies/#{type}.html", locals: { u: url }, layout: layout
      premailer = Premailer.new(substitute_in(body), with_html_string: true,
        warn_level: Premailer::Warnings::SAFE)

      headers = {
        subject: substitute_in(subject),
        tags: [type],
      }.merge(@headers)

      if @users.present?
        merge_vars = []
        @users.each do |user|
          this_users_vars ||= []
          premailer.to_plain_text.scan(/\|[a-z_:]+\|/).each do |token|
            substitute = get_value_for_token(token, { user: user })
            tag_name = token.gsub(/:/, '_').gsub(/\*/, '').gsub(/\|/, '')
            this_users_vars << { name: tag_name, content: substitute }
          end
          merge_vars << { rcpt: user.email, vars: this_users_vars } if this_users_vars.any?
        end
        # raise merge_vars.inspect
        if merge_vars.any?
          # it's weird to pass an array to mandrill via the mail headers, so we
          # pass a string and remake it an array on the mandrill side
          headers[:merge_vars] = merge_vars.to_s
          headers[:merge] = true
          headers[:merge_language] = 'mailchimp'
        end
      end

      # raise premailer.to_inline_css.to_s

      # format merge tags for mandrill
      plain_text = premailer.to_plain_text.gsub(/\|[a-z_:]+\|/){|m| "*#{m.gsub(/:/, '_')}*" }
      inline_css = premailer.to_inline_css.gsub(/\|[a-z_:]+\|/){|m| "*#{m.gsub(/:/, '_')}*" }

      output_email = mail(headers.merge(default_headers)) do |format|
        format.text { render text: plain_text }
        format.html { render text: inline_css }
      end

      LogLine.create(source: :mailer, log_type: :mail_sent,
        message: "Email sent of type: #{type} to #{(headers[:to])}")

      output_email
    end

    def substitute_in text
      text.scan(/\|[a-z_:]+\|/).each do |token|
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