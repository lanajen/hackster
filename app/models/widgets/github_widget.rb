class GithubWidget < Widget
  define_attributes [:repo]
  validates :repo, format: { with: /github\.com\/[0-9a-z_]+\/[0-9a-z_]+\z/,
    message: 'is not a valid Github repository' }, allow_blank: true

  def self.model_name
    Widget.model_name
  end

  def repo_name
    return if repo.blank?
    repo.match(/github.com\/(.+)/)[1]
  end
end
