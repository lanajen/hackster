object false
node(:project_count) { |n| @project_count }
node(:external_project_count) { |n| @external_project_count }
node(:comment_count) { |n| @comment_count }
node(:like_count) { |n| @like_count }
node(:follow_count) { |n| @follow_count }
node(:views_count) { |n| @views_count }
node(:project_views_count) { |n| @project_views_count }
node(:new_projects_count) { |n| @new_projects_count }
node(:new_comments_count) { |n| @new_comments_count }
node(:new_likes_count) { |n| @new_likes_count }
node(:new_follows_count) { |n| @new_follows_count }
node(:new_views_count) { |n| @new_views_count }
node(:new_project_views_count) { |n| @new_project_views_count }

node :heroes do |n|
  @heroes.map do |u|
    { name: u.name, url: url_for([u, only_path: false]), projects_count: u.count }
  end
end
node :fans do |n|
  @fans.map do |u|
    { name: u.name, url: url_for([u, only_path: false]), respects_count: u.count }
  end
end
node :most_respected_projects do |n|
  @most_respected_projects.map do |p|
    { name: p.name, url: url_for([p, only_path: false]), respects_count: p.count }
  end
end
node :most_viewed_projects do |n|
  @most_viewed_projects.map do |p|
    { name: p.name, url: url_for([p, only_path: false]), views_count: p.count }
  end
end
node :most_recent_projects do |n|
  @most_recent_projects.map do |p|
    { name: p.name, url: url_for([p, only_path: false]), date: p.created_at }
  end
end
node :most_recent_comments do |n|
  @most_recent_comments.map do |c|
    p = c.commentable
    u = c.user
    {
      date: c.created_at,
      body: c.body,
      project: { name: p.name, url: url_for([p, only_path: false]) },
      user: { name: u.name, url: url_for([u, only_path: false]) },
    }
  end
end
node :most_recent_followers do |n|
  @most_recent_followers.map do |f|
    u = f.user
    {
      date: f.created_at,
      user: { name: u.name, url: url_for([u, only_path: false]) },
    }
  end
end

node(:new_projects) do |n|
  ActiveRecord::Base.connection.exec_query(@new_projects_sql % @platform.id).each do |r|
    r.inspect
  end
end
node(:new_respects) do |n|
  ActiveRecord::Base.connection.exec_query(@new_respects_sql % @platform.id).each do |r|
    r.inspect
  end
end
node(:new_views) do |n|
  ActiveRecord::Base.connection.exec_query(@new_views_sql % @platform.id).each do |r|
    r.inspect
  end
end
node(:new_project_views) do |n|
  ActiveRecord::Base.connection.exec_query(@new_project_views_sql % @platform.id).each do |r|
    r.inspect
  end
end