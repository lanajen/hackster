class ConversationsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :load_conversation, only: [:show, :update, :destroy]

  def index
    title "Messages"
    @conversations = Conversation.for(current_user).paginate(page: params[:page], per_page: 10)

    respond_to do |format|
      format.html { render @conversations if request.xhr? }
    end
  end

  def show
    authorize! :read, @conversation
    title "Messages > #{@conversation.subject}"
    @conversation.mark_as_read! current_user
    @receipts = @conversation.receipts
    @receipts = if current_user.is?(:admin)
      receipts = []
      @receipts.inject([]){|mem, r| receipts << r unless r.receivable_id.in?(mem); mem << r.receivable_id; mem}
      receipts
    else
      @receipts.where(receipts: { user_id: current_user.id })
    end
  end

  def new
    @conversation = Conversation.new
    if params[:recipient_id] and params[:recipient_id].to_i != current_user.id and @recipient = User.find_by_id(params[:recipient_id])
      title "New message to #{@recipient.name}"
      @conversation.recipient_id = @recipient.id
    else
      redirect_to conversations_path, alert: "We couldn't find a member to contact!" and return
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
      @receipts = @conversation.receipts.where(receipts: { user_id: current_user.id })
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
    def load_conversation
      @conversation = Conversation.find params[:id]
    end
end