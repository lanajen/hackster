class RepoWidget < Widget
  define_attributes [:repo]

  def self.model_name
    Widget.model_name
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
end
