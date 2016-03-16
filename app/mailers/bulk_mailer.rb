class BulkMailer < BaseMailer

  def deliver_email recipients, context, template, opts={}
    super

    set_header :to, extract_emails(recipients)
    send_email recipients,  template
  end

  private
    def extract_emails users
      users.map { |user| user.email }
    end
end