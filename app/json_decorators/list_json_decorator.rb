class ListJsonDecorator < BaseJsonDecorator
  def node
    _node = hash_for(%w(id name))
    _node[:userName] = model.user_name
    _node[:isInitiallyChecked] = (@opts[:project_lists].present? && @opts[:project_lists].include?(model.id))
    _node
  end
end