class Tech < Group
  include Taggable

  store :websites, accessors: [:facebook_link, :twitter_link, :linked_in_link,
    :google_plus_link, :youtube_link, :website_link, :blog_link, :github_link,
    :forums_link, :documentation_link]

  validates :user_name, :full_name, presence: true
  validates :user_name, uniqueness: { scope: [:type] }
  validates :user_name, :new_user_name, length: { in: 3..100 }, if: proc{|t| t.persisted?}
  before_validation :update_user_name

  taggable :tech_tags

  def self.model_name
    Group.model_name
  end

  def projects
    # Project.includes(:tech_tags).where(tags: { name: tech_tags.pluck(:name) })
    Project.includes(:tech_tags).where('lower(tags.name) IN (?)', tech_tags.pluck(:name).map{|n| n.downcase })
    # SearchRepository.new(q: tech_tags_string).search.results
  end

  def update_user_name
    # raise "#{new_user_name}|#{user_name}|#{@old_user_name}"
    tech = Tech.new full_name: full_name_was
    was_auto_generated = (@old_user_name == tech.generate_user_name)
    new_user_name_changed = (new_user_name != @old_user_name)

    generate_user_name if was_auto_generated or user_name.blank?
    assign_new_user_name if new_user_name_changed
  end
end