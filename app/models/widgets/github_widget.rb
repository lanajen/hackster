class GithubWidget < Widget
  define_attributes [:repo]

  def self.model_name
    Widget.model_name
  end

  def repo_name
    return if repo.blank?
    repo.match(/github.com\/(.+)/)[1]
  end
end
