class GithubEmbed < RepoEmbed
  def initialize id
    @id = id.gsub(/\.git$/, '')
  end
end