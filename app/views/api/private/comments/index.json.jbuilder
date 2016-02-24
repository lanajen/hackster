json.comments sort_comments(@comments) do |comment_id, comment|
  json.root comment[:root], partial: 'api/private/comments/comment', as: :comment
  json.children comment[:children] do |c|
    json.partial! 'api/private/comments/comment', comment: c
  end
end