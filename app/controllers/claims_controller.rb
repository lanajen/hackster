class ClaimsController < ApplicationController
  before_filter :authenticate_user!

  def create
    @group = Group.find_by_id params[:group_id]
    send_admin_message
    redirect_to @group, notice: "Thanks! We'll review your claim and get back to you shortly."
  end

  private
    def send_admin_message
      @message = Message.new(
        from_email: current_user.email,
        message_type: 'generic'
      )
      @message.subject = "New claim request"
      @message.body = "<p>Hi</p><p>I would like to claim this page: <a href='#{url_for(@group)}'>#{@group.name}</a>.</p>"
      @message.body += "<p>Personal message:<br>#{params[:message]}</p>"
      @message.body += "<p>Thanks!<br><a href='#{hacker_url(current_user.id)}'>#{current_user.name}</a></p>"
      BaseMailer.enqueue_generic_email(@message)
    end
end