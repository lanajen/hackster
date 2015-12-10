json.comments sort_comments(@comments) do |comment_id, comment|
  json.root comment[:root], partial: 'api/v1/comments/comment', as: :comment
  json.children comment[:children] do |c|
    json.partial! 'api/v1/comments/comment', comment: c
  end
end