class Platform < List
  PROJECT_IDEAS_PHRASING = ['"No #{name} yet?"', '"Have ideas on what to build with #{name}?"']

  has_many :active_members, -> { where("members.requested_to_join_at IS NULL OR members.approved_to_join = 't'") }, foreign_key: :group_id, class_name: 'PlatformMember'
  has_many :announcements, as: :threadable, dependent: :destroy
  has_many :challenges
  has_many :members, dependent: :destroy, foreign_key: :group_id, class_name: 'PlatformMember'
  has_one :client_subdomain
  has_one :company_logo, as: :attachable, dependent: :destroy
  has_one :logo, as: :attachable, dependent: :destroy
  has_one :slug, as: :sluggable, dependent: :destroy, class_name: 'SlugHistory'

  attr_accessible :forums_link, :documentation_link, :crowdfunding_link,
    :buy_link, :shoplocket_link, :cover_image_id, :accept_project_ideas,
    :project_ideas_phrasing, :client_subdomain_attributes, :logo_id,
    :download_link, :company_logo_id

  accepts_nested_attributes_for :client_subdomain

  # before_save :update_user_name

  store_accessor :websites, :forums_link, :documentation_link,
    :crowdfunding_link, :buy_link, :shoplocket_link, :download_link
  set_changes_for_stored_attributes :websites

  store_accessor :properties, :accept_project_ideas, :project_ideas_phrasing,
    :active_challenge
  set_changes_for_stored_attributes :properties

  parse_as_booleans :properties, :accept_project_ideas, :active_challenge,
    :hidden

  taggable :platform_tags

  # beginning of search methods
  tire do
    mapping do
      indexes :id,              index: :not_analyzed
      indexes :name,            analyzer: 'snowball', boost: 1000
      indexes :platform_tags,       analyzer: 'snowball', boost: 500
      indexes :mini_resume,     analyzer: 'snowball', boost: 100
      indexes :created_at
    end
  end

  def to_indexed_json
    {
      _id: id,
      name: name,
      model: self.class.name.underscore,
      mini_resume: mini_resume,
      platform_tags: platform_tags_string,
      created_at: created_at,
      popularity: 1000.0,
    }.to_json
  end

  def self.index_all
    index.import public
  end
  # end of search methods

  def self.for_thumb_display
    includes(:avatar).includes(:cover_image)
  end

  def company_logo_id=(val)
    self.company_logo = CompanyLogo.find_by_id(val)
  end

  def generate_user_name
    return if full_name.blank?

    slug = name.gsub(/[^a-zA-Z0-9\-_]/, '-').gsub(/(\-)+$/, '').gsub(/^(\-)+/, '').gsub(/(\-){2,}/, '-').downcase

    # make sure it doesn't exist
    if result = SlugHistory.where(value: slug).first
      return if self == result
      # if it exists add a 1 and increment it if necessary
      slug += '1'
      while SlugHistory.where(value: slug).first
        slug.succ!
      end
    end
    self.user_name = slug
  end

  def project_ideas_phrasing
    super || project_ideas_phrasing_options[0]
  end

  def project_ideas_phrasing_options
    PROJECT_IDEAS_PHRASING.map{|t| eval(t) }
  end

  # def projects
  #   # Project.includes(:platform_tags).where(tags: { name: platform_tags.pluck(:name) })
  #   Project.public.includes(:platform_tags).references(:tags).where('lower(tags.name) IN (?)', platform_tags.pluck(:name).map{|n| n.downcase })
  #   # SearchRepository.new(q: platform_tags_string).search.results
  # end

  def logo_id=(val)
    self.logo = Logo.find_by_id(val)
  end

  def shoplocket_token
    return unless shoplocket_link.present?

    shoplocket_link.split(/\//)[-1]
  end

  private
    def user_name_is_unique
      return unless new_user_name.present?

      slug = SlugHistory.where("LOWER(slug_histories.value) = ?", new_user_name.downcase).first
      errors.add :new_user_name, 'is already taken' if slug and slug.sluggable != self
    end
end