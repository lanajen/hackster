Group.where(type: 'Tech').update_all(type: 'Platform')
Tag.where(type: 'TechTag').update_all(type: 'PlatformTag')
Member.where(type: 'TechMember').update_all(type: 'PlatformMember')
ThreadPost.where(type: 'BlogPost').update_all(type: 'BuildLog')
ThreadPost.where(type: 'HacksterBlogPost').update_all(type: 'BlogPost')

# don't forget to reindex
Platform.index_all
Project.index_all