Broacast.update_all("user_id = broadcastable_id")
Broadcast.where(context_model_type: 'Project').update_all("project_id = context_model_id")
Broadcast.where(context_model_type: 'Comment').each{|b| b.project_id = b.context_model.commentable_id;b.save }