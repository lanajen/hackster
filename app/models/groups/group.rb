class Group < ActiveRecord::Base

  ACCESS_LEVELS = {
    'Anyone without approval' => 'anyone',
    'Anyone can request access' => 'request',
    'Only people who are explicitely invited' => 'invite',
  }
  PROJECT_SORTING = {
    'Trending (most popular first)' => 'trending',
    'Most impressions first' => 'popular',
    'Most recent first' => 'recent',
    'Most respects first' => 'respected',
  }
  SORTING = {
    'followers' => :most_members,
    'members' => :most_members,
    'name' => :alphabetical_sorting,
    'projects' => :most_projects,
    'last_project' => :most_recent_project,
  }

  include EditableSlug
  include HasDefault
  include HstoreColumn
  include HstoreCounter
  include WebsitesColumn

  editable_slug :user_name

  has_many :active_members, -> { where("members.requested_to_join_at IS NULL OR members.approved_to_join = 't'") }, foreign_key: :group_id, class_name: 'Member'
  has_many :featured_projects, -> { where("project_collections.workflow_state = 'featured'") }, source: :project, through: :project_collections
  has_many :granted_permissions, as: :grantee, class_name: 'Permission'
  has_many :impressions, dependent: :destroy, class_name: 'GroupImpression'
  has_many :members, dependent: :destroy
  has_many :permissions, as: :permissible
  has_many :project_collections, dependent: :destroy, as: :collectable
  # see https://github.com/rails/rails/issues/19042#issuecomment-91405982 about
  # "counter_cache: :this_is_not_a_column_that_exists"
  has_many :projects, through: :project_collections, counter_cache: :this_is_not_a_column_that_exists do
    # TODO: see if this can be delegated to ProjectCollection
    def visible
      where(project_collections: { workflow_state: ProjectCollection::VALID_STATES })
    end
  end
  has_many :users, through: :members do
    def active
      where("members.requested_to_join_at IS NULL OR members.approved_to_join = 't'")
    end
  end
  has_one :avatar, as: :attachable, dependent: :destroy
  has_one :cover_image, as: :attachable, dependent: :destroy

  attr_accessible :avatar_attributes, :type, :email, :mini_resume, :city,
    :country, :user_name, :full_name, :members_attributes, :avatar_id,
    :permissions_attributes, :access_level, :cover_image_id, :project_sorting,
    :admin_email, :virtual

  attr_accessor :admin_email, :require_admin_email

  accepts_nested_attributes_for :avatar, :members, :permissions,
    allow_destroy: true

  has_websites :websites, :facebook, :twitter, :linked_in, :google_plus,
    :youtube, :website, :blog, :github, :instagram, :flickr, :reddit, :pinterest

  hstore_column :hproperties, :default_project_sorting, :string, default: 'trending'
  hstore_column :hproperties, :hidden, :boolean, default: true
  hstore_column :hproperties, :last_project_time, :datetime, order: [{ sort_by: :desc, method_name: :most_recent_project }]
  hstore_column :hproperties, :slack_token, :string
  hstore_column :hproperties, :slack_hook_url, :string

  counters_column :hcounters_cache
  has_counter :members, 'members.count', accessor: false
  has_counter :projects, 'project_collections.visible.count', accessor: false

  validates :user_name, :new_user_name, length: { in: 3..100 },
    format: { with: /\A[a-zA-Z0-9_\-]+\z/, message: "accepts only letters, numbers, underscores '_' and dashes '-'." }, allow_blank: true, if: proc{|t| t.persisted?}
  validates :user_name, :new_user_name, exclusion: { in: %w(projects terms privacy admin infringement_policy search users communities hackerspaces hackers lists) }, allow_blank: true
  validates :email, length: { maximum: 255 }, format: { with: EMAIL_REGEXP }, allow_blank: true
  validates :mini_resume, length: { maximum: 160 }
  validate :admin_email_is_present
  before_validation :clean_members
  after_validation :add_errors_to_user_name
  before_save :ensure_invitation_token

  has_default :access_level, 'anyone' do |instance|
    instance.read_attribute(:access_level)
  end

  include AlgoliaSearchHelpers

  def self.algolia_index_name
    "hackster_#{Rails.env}_#{self.name.underscore}"
  end

  def self.index_all limit=nil
    algolia_batch_import publyc, limit
  end

  def to_indexed_json
    {
      # for locating
      id: id,
      model: self.class.name,
      objectID: algolia_id,

      # for searching
      name: name,
      pitch: mini_resume,

      # for ranking
      members_count: members_count,
      impressions_count: impressions_count,
      last_project_time: last_project_time.to_i,
      projects_count: projects_count,
    }
  end

  def self.default_permission
    'read'
  end

  def self.default_project_sorting
    'trending'
  end

  def self.alphabetical_sorting
    order full_name: :asc
  end

  def self.most_members
    order members_count: :desc
  end

  def self.most_projects
    order projects_count: :desc
  end

  def avatar_id=(val)
    attribute_will_change! :avatar
    self.avatar = Avatar.find_by_id(val)
  end

  def cover_image_id=(val)
    attribute_will_change! :cover_image
    self.cover_image = CoverImage.find_by_id(val)
  end

  def project_sorting
    default_project_sorting.presence || self.class.default_project_sorting
  end

  def project_sorting=(val)
    self.default_project_sorting = val
  end

  def default_user_name
    name.gsub(/[^a-zA-Z0-9\-_]/, '-').gsub(/(\-)+$/, '').gsub(/^(\-)+/, '').gsub(/(\-){2,}/, '-').downcase[0...100]
  end

  def generate_user_name
    return if full_name.blank?

    slug = default_user_name

    # make sure it doesn't exist
    if result = self.class.where(user_name: slug).first
      unless self == result
        # if it exists add a 1 and increment it if necessary
        slug = slug[0...99] + '1'
        while self.class.where(user_name: slug).first
          slug.gsub!(/([0-9]+$)/, ($1.to_i + 1).to_s)
        end
      end
    end
    self.user_name = slug
  end

  def identifier
    self.class.name.to_s.underscore
  end

  def is? *group_types
    self.class.name.underscore.in? group_types.map{|v| v.to_s }
  end

  def invite_with_emails emails, invited_by=nil, message=nil
    emails.each do |email|
      invite_with_email email, invited_by, message
    end
  end

  def invite_with_email email, invited_by=nil, message=nil
    unless user = User.find_by_email(email)
      user = User.invite!({ email: email }, invited_by) do |u|
        u.skip_invitation = true
      end
    end
    member = members.create user_id: user.id, invitation_sent_at: Time.now, invited_by: invited_by
    user.deliver_invitation_with({ model: member, personal_message: message }) if member.persisted? and user.invited_to_sign_up?
  end

  def enqueue_invites emails, invited_by=nil, message=nil
    MailerQueue.perform_async 'send_group_invites', id, emails.join(','), invited_by.id, message
  end

  def name
    full_name.presence || user_name
  end

  private
    def add_errors_to_user_name
      if errors[:new_user_name]
        errors[:new_user_name].each{|e| errors.add :user_name, e }
      end
    end

    def admin_email_is_present
      errors.add :admin_email, 'is required, or please log in first' if require_admin_email and admin_email.blank?
    end

    def clean_members
      members.each do |member|
        members.delete(member) if member.new_record? and member.user.nil?
      end
    end

    def ensure_invitation_token
      self.invitation_token = SecureRandom.urlsafe_base64(nil, false) if invitation_token.nil?
    end

    def skip_website_check
      []
    end
end
