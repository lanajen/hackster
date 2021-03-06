class BitbucketWidget < RepoWidget
  validates :repo, format: { with: /bitbucket\.org\/[0-9a-zA-Z_\-]+\/[0-9a-zA-Z_\-]+/,
    message: 'is not a valid Bitbucket repository' }, allow_blank: true

  def provider
    'bitbucket'
  end

  def repo_regexp
    /bitbucket\.org\/([0-9a-zA-Z_\-]+\/[0-9a-zA-Z_\-]+)/
  end
end
