class CodeRepoWidget < EmbedWidget
  def valid_repo?
    embed.code_repo?
  end
end