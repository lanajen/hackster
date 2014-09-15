class ExpertRequestsController < ApplicationController
  def new
    title "Idea to market"
    @expert_request = ExpertRequest.new
  end

  def create
    @expert_request = ExpertRequest.new params[:expert_request]

    if @expert_request.valid?
      @message = Message.new(
        from_email: current_user.try(:email),
        message_type: 'generic'
      )
      @message.subject = "New expert request"
      @message.body = "<p>Hi<br><p>Please help me connect with an expert:<br>"
      @message.body += "<p>"
      @message.body += "<b>Project description: </b>#{@expert_request.project_description}<br>"
      if @expert_request.project_id and project = Project.find(@expert_request.project_id)
        @message.body += "<b>Project: </b><a href='#{url_for(project)}'>#{project.name}</a><br>"
      end
      @message.body += "<b>Stage: </b>#{@expert_request.stage}<br>"
      @message.body += "<b>Area of expertise: </b>#{@expert_request.expertise_area.to_sentence}<br>"
      @message.body += "<b>Request description: </b>#{@expert_request.request_description}<br>"
      @message.body += "<b>Budget: </b>#{@expert_request.budget}<br>"
      @message.body += "<b>Comments: </b>#{@expert_request.comments}<br>"
      @message.body += "<b>Name: </b>#{@expert_request.name}<br>"
      @message.body += "<b>Phone: </b>#{@expert_request.phone}<br>"
      @message.body += "<b>Email: </b>#{@expert_request.email}<br>"
      @message.body += "<b>Location: </b>#{@expert_request.location}"
      @message.body += "</p>"
      @message.body += "<p>Thanks!<br><a href='#{url_for(current_user)}'>#{current_user.name}</a><br>" if user_signed_in?
      BaseMailer.enqueue_generic_email(@message)
      LogLine.create source: 'expert_request', type: 'expert_request', message: @message.body

      redirect_to root_path, notice: "Thanks for your request, we will let you know once we've matched you with an expert!"
    else
      render 'new'
    end
  end
end