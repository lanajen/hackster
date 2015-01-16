class ChatMessage < ActiveRecord::Base
  belongs_to :group
  belongs_to :user

  attr_accessible :user_id, :group_id, :raw_body, :created_at
  validates :user_id, :group_id, presence: true
  before_save :parse_body

  private
    def parse_body
      return unless raw_body

      slack = parse_from_slack(raw_body)

      markdown = Redcarpet::Markdown.new(Redcarpet::Render::SingleLineHTML, autolink: true, escape_html: true)
      self.body = markdown.render(slack)
    end

    def parse_from_slack text
      text.gsub!(/<(@?[^>]+)>/) do
        if $1.starts_with? '@'
          user_id = $1[1..-1]
          if user = User.joins(:authorizations).where(authorizations: { uid: user_id, provider: 'Slack' }).first
            "@[#{user.name}](/hackers/#{user.id})"
          else
            "@#{user_id}"
          end
        else
          $1
        end
      end
      text
    end
end
