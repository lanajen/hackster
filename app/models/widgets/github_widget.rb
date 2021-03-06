class GithubWidget < RepoWidget
  validates :repo, format: { with: /github\.com\/[0-9a-zA-Z_\-]+\/[0-9a-zA-Z_\-]+/,
    message: 'is not a valid Github repository' }, allow_blank: true

  def provider
    'github'
  end

  def repo_regexp
    /github\.com\/([0-9a-zA-Z_\-]+\/[0-9a-zA-Z_\-]+)/
  end
end
