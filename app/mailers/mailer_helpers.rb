module MailerHelpers
  DEFAULT_EMAIL = 'Ben from Hacker.io<ben@hacker.io>'

  extend ActionView::Helpers::UrlHelper

  def send_notification type, context
    @headers = {
      :to => DEFAULT_EMAIL,
    }
    send_email type, context
  end

  def send_single_email type, context
    @user = context[:user]
    @headers = {
      :to => @user.email,
    }
    send_email type, context
  end

  def send_bulk_email type, context
    @users = context[:users]
    @headers = {
      :to => DEFAULT_EMAIL,
    }
    send_email type, context
  end

  def send_email type, context

    body = render_to_string "mailers/bodies/#{type}"
    subject = render_to_string "mailers/subjects/#{type}"
    premailer = Premailer.new(substitute_in(body, context), :with_html_string => true,
      :warn_level => Premailer::Warnings::SAFE)

    headers = {
      :subject => substitute_in(subject, context),
    }.merge(@headers)

    if @users.present?
      premailer.to_plain_text.scan(/\|[a-z_]*\|/).each do |token|
        substitutes = @users.map { |user| get_value_for_token(token, { user: user }) }
        sendgrid_substitute token, substitutes
      end
    end

    output_email = mail(headers.merge(default_headers)) do |format|
      format.text { render :text => premailer.to_plain_text }
      format.html { render :text => premailer.to_inline_css }
    end

    # Output any CSS warnings
    premailer.warnings.each do |w|
      msg = "#{w[:message]} (#{w[:level]}) may not render properly in #{w[:clients]}"
    end

    output_email
  end

  private
    def default_headers
      {
        :from => DEFAULT_EMAIL,
        :reply_to => DEFAULT_EMAIL,
      }
    end

    def get_value_for_token token, context
      user = context[:user] if context.include? :user
      invite = context[:invite_request] if context.include? :invite_request
      error = context[:log_line] if context.include? :log_line
      token = token.gsub(/\|/, '')
      case token.to_sym
      when :account_with_auth_token_link
        subscription_url(:auth_token => user.authentication_token, :host => APP_CONFIG['default_host'])
      when :new_invite_with_auth_token_link
        new_user_invitation_url(:auth_token => user.authentication_token, :host => APP_CONFIG['default_host'])
      when :email_confirmation_link
        user_confirmation_url(:confirmation_token => user.confirmation_token, :host => APP_CONFIG['default_host'])
      when :invitation_link
        accept_user_invitation_url(:invitation_token => user.invitation_token, :host => APP_CONFIG['default_host'])
      when :password_reset_link
        edit_user_password_url(:reset_password_token => user.reset_password_token, :host => APP_CONFIG['default_host'])
      else
        split_token = token.split '_', 2
        object = split_token[0]
        attribute = split_token[1]
        if context.include? object.to_sym and context[object.to_sym].respond_to? attribute
          context[object.to_sym].send(attribute).to_s
        else
          msg = "Called for unknown token: #{token}."
          logger.info msg
          return token
        end
      end
    end

    def substitute_in text, context
      text.scan(/\|[a-z_]*\|/).each do |token|
        if substitute = get_value_for_token(token, context)
          text = text.gsub(token, substitute)
        end
      end
      text
    end
end
