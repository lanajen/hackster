class RepoWidget < Widget
  define_attributes [:repo]

  def self.model_name
    Widget.model_name
  end

  def default_label
    'Code repository'
  end

  def identifier
    'repo_widget'
  end

  def provider
    raise NoMethodError
  end

  def repo_name
    return if repo.blank?
    repo.match(repo_regexp)[1]
  end

  def to_text
    repo.present? ? "<h3>#{name}</h3><div contenteditable='false' class='embed-frame' data-type='url' data-url='#{repo}' data-caption=''></div>" : ''
  end
end
