class BaseMailer < ActionMailer::Base
  DEFAULT_EMAIL = 'Hackster.io<help@hackster.io>'
  add_template_helper ApplicationHelper
  add_template_helper UrlHelper

  def deliver_email recipient_or_recipients, context, template, opts={}
    puts "#{Time.now.to_s} - Sending email '#{template}'."

    @context = context
  end

  private
    def context
      @context
    end

    def default_headers
      {
        from: context[:from_email] || DEFAULT_EMAIL,
        reply_to: context[:reply_to].presence || context[:from_email] || DEFAULT_EMAIL,
      }
    end

    def get_value_for_token token, opts={}
      author = context[:author] if context.include? :author
      invite = context[:invite] if context.include? :invite
      issue = context[:issue] if context.include? :issue
      project = context[:project] if context.include? :project
      user = context[:user] if context.include? :user
      user = opts[:user] if opts.include? :user
      group = context[:group] if context.include? :group
      comment = context[:comment] if context.include? :comment

      token = token.gsub(/\|/, '').gsub(/\*/, '')
      case token.to_sym
      when :author_link
        url.user_url(author)
      when :comment_body
        ActionView::Base.full_sanitizer.sanitize comment.body
      when :email_confirmation_link
        url.user_confirmation_url(confirmation_token: context[:devise_token])
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
        url.edit_user_password_url(reset_password_token: context[:devise_token])
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
          if context.include? object.to_sym and context[object.to_sym].respond_to? attribute
            context[object.to_sym].send(attribute).to_s
          else
            msg = "Called for unknown token: #{token}."
            LogLine.create(source: :mailer, log_type: :unknown_token,
              message: msg)
            return token
          end
        end
      end
    end

    def headers
      @headers || {}
    end

    def set_header header, value
      @headers ||= {}
      @headers[header] = value
    end

    def send_email recipient_or_recipients, type, opts={}
      context[:devise_token] = opts['token']
      context[:personal_message] = opts['personal_message']
      context[:email_template] = type
      layout = type == 'new_projects' ? 'nicer_email' : 'email'
      current_platform = opts[:current_platform] || context[:current_platform]
      if current_platform.present?
        prepend_view_path "app/views/whitelabel/#{current_platform.user_name}"
      end
      subject = render template: "mailers/subjects/#{type}"
      body = render template: "mailers/bodies/#{type}.html", locals: { u: url }, layout: layout
      premailer = Premailer.new(substitute_in(body), with_html_string: true,
        warn_level: Premailer::Warnings::SAFE)

      set_header :subject, substitute_in(subject)
      set_header :tags, [type]

      if recipient_or_recipients.kind_of?(Array)
        recipients = recipient_or_recipients
        recipient_variables = {}
        recipients.each do |user|
          this_users_vars = {}
          premailer.to_plain_text.scan(/\|[a-z_:]+\|/).each do |token|
            substitute = get_value_for_token(token, { user: user })
            tag_name = token.gsub(/:/, '_').gsub(/\*/, '').gsub(/\|/, '')
            this_users_vars[tag_name] = substitute
          end
          recipient_variables[user.email] = this_users_vars if this_users_vars.any?
        end
        # raise merge_vars.inspect
        if recipient_variables.any?
          set_header :recipient_variables, recipient_variables
        end
      end

      # raise premailer.to_inline_css.to_s

      # format merge tags for mandrill
      plain_text = premailer.to_plain_text.gsub(/\|[a-z_:]+\|/){|m| "*#{m.gsub(/:/, '_')}*" }
      inline_css = premailer.to_inline_css.gsub(/\|[a-z_:]+\|/){|m| "*#{m.gsub(/:/, '_')}*" }

      Rails.logger.debug inline_css if Rails.env.development?

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