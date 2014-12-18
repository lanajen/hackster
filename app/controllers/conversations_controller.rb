class ConversationsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :load_conversation, only: [:show, :update, :destroy]
  before_filter :get_box

  def index
    if @box.eql? "inbox"
      title "Messages > Inbox"
      @conversations = Conversation.inbox_for(current_user).paginate(page: params[:page])
    elsif @box.eql? "sent"
      title "Messages > Sent"
      @conversations = Conversation.sent_for(current_user).paginate(page: params[:page])
    end

    respond_to do |format|
      format.html { render @conversations if request.xhr? }
    end
  end

  def show
    authorize! :read, @conversation
    title "Messages > #{@conversation.subject}"
    @conversation.mark_as_read! current_user
  end

  def new
    @conversation = Conversation.new
    if params[:recipient_id] and params[:recipient_id].to_i != current_user.id and @recipient = User.find_by_id(params[:recipient_id])
      title "New message to #{@recipient.name}"
      @conversation.recipient_id = @recipient.id
    else
      redirect_to conversations_path, alert: "We couldn't find a hacker to contact!" and return
    end
  end

  def create
    @conversation = Conversation.new(params[:conversation])
    @conversation.sender_id = current_user.id

    if @conversation.save
      redirect_to (params[:redirect_to] || conversations_path), notice: "Message sent!"
    else
      @recipient = User.find_by_id @conversation.recipient_id
      render :new
    end
  end

  def update
    authorize! :edit, @conversation
    @conversation.assign_attributes params[:conversation]
    @conversation.sender_id = current_user.id

    if @conversation.save
      redirect_to @conversation, notice: "Message sent!"
    else
      render :show
    end
  end

  def destroy
    @conversation.move_to_trash! current_user

    respond_to do |format|
      format.html { redirect_to conversations_path, notice: "Conversation deleted." }
    end
  end

  private
    def get_box
      if params[:box].blank? or !%w(inbox sent trash).include? params[:box]
        params[:box] = 'inbox'
      end

      @box = params[:box]
    end

    def load_conversation
      @conversation = Conversation.find params[:id]
    end
end