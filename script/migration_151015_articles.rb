BaseArticle.where(type: 'Protip').update_all(type: 'Article')

Comment.where(commentable_type: 'Project').update_all(commentable_type: 'BaseArticle')
Attachment.where(attachable_type: 'Project').update_all(attachable_type: 'BaseArticle')
PartJoin.where(partable_type: 'Project').update_all(partable_type: 'BaseArticle')
Respect.where(respectable_type: 'Project').update_all(respectable_type: 'BaseArticle')
Widget.where(widgetable_type: 'Project').update_all(widgetable_type: 'BaseArticle')
Permission.where(permissible_type: 'Project').update_all(permissible_type: 'BaseArticle')
FollowRelation.where(followable_type: 'Project').update_all(followable_type: 'BaseArticle')
ThreadPost.where(threadable_type: 'Project').update_all(threadable_type: 'BaseArticle')
SlugHistory.where(sluggable_type: 'Project').update_all(sluggable_type: 'BaseArticle')
Tag.where(taggable_type: 'Project').update_all(taggable_type: 'BaseArticle')
Impression.where(impressionable_type: 'Project').update_all(impressionable_type: 'BaseArticle')

Article.all.each{|a| if a.content_type == 'tutorial' ; a.content_type = :protip; a.save; end; }