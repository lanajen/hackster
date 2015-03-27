class CodeRepository < CodeEntity
  attr_accessible :repository

  validates :repository, presence: true
  validate :repository_is_recognized

  private
    def repository_is_recognized
      return unless repository.present?
      # raise 'yo'
      embed = Embed.new url: repository
      # raise embed.inspect
      errors.add :repository, "is not recognized. Please insert the HTTP link of the repository." unless embed.provider and embed.provider_name.to_s.in? %(bitbucket codebender gist github snip2code)
    end
end
