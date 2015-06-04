class Admin::ConversationsController < Admin::BaseController

  def destroy
    Conversation.find(params[:id]).destroy

    respond_to do |format|
      format.html { redirect_to admin_messages_path, notice: "Conversation deleted." }
    end
  end
end