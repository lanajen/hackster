class Challenge < ActiveRecord::Base
  PAST_STATES = %w(judging judged)
  OPEN_SUBMISSION_STATES = %w(pre_contest_in_progress in_progress)
  REGISTRATION_OPEN_STATES = %w(pre_registration pre_contest_in_progress pre_contest_ended in_progress)
  REMINDER_TIMES = [2.weeks, 5.days, 24.hours]
  TOKEN_PARSABLE_ATTRIBUTES = %w(description how_to_enter eligibility judging_criteria requirements rules)
  TOKENABLE_ATTRIBUTES = %w(pre_registration_date pre_contest_start_date pre_contest_end_date pre_winners_announced_date start_date end_date winners_announced_date free_hardware_end_date)
  VISIBLE_STATES = %w(in_progress judging judged)
  VOTING_START_OPTIONS = {
    'Now' => :now,
    'When the challenge ends' => :end,
  }

  include HstoreColumn
  include HstoreCounter
  include TablelessAssociation
  include Workflow

  belongs_to :platform
  has_many :sponsor_relations, dependent: :destroy
  has_many :sponsors, through: :sponsor_relations, class_name: 'Group'
  has_many :admins, through: :challenge_admins, source: :user
  has_many :categories, -> { order("LOWER(challenge_categories.name)") }, class_name: 'ChallengeCategory'
  has_many :challenge_admins
  has_many :entries, class_name: 'ChallengeEntry', dependent: :destroy
  has_many :entrants, -> { uniq }, through: :entries, source: :user
  has_many :faq_entries, as: :threadable
  has_many :ideas, class_name: 'ChallengeIdea', dependent: :destroy, inverse_of: :challenge
  has_many :idea_entrants, -> { uniq }, through: :ideas, source: :user
  has_many :notifications, as: :notifiable, dependent: :delete_all
  has_many :participants, -> { uniq }, through: :projects, source: :users
  has_many :prizes, -> { order(:position) }, dependent: :destroy
  # see https://github.com/rails/rails/issues/19042#issuecomment-91405982 about
  # "counter_cache: :this_is_not_a_column_that_exists"
  has_many :projects, -> { order('challenge_projects.created_at ASC') },
    through: :entries, counter_cache: :this_is_not_a_column_that_exists do
    def valid
      where("challenge_projects.workflow_state IN (?)", ChallengeEntry::APPROVED_STATES)
    end
  end
  has_many :registrations, dependent: :destroy, class_name: 'ChallengeRegistration'
  has_many :registrants, -> { order(:full_name) }, through: :registrations, source: :user
  has_many :votes, through: :entries
  has_many_tableless :challenge_entry_fields, order: :position
  has_many_tableless :challenge_idea_fields, order: :position
  has_one :avatar, as: :attachable, dependent: :destroy
  has_one :cover_image, as: :attachable, dependent: :destroy
  validates :name, :slug, presence: true
  validates :teaser, :custom_tweet, :after_submit_idea_tweet, length: { maximum: 140 }
  validates :mailchimp_api_key, :mailchimp_list_id, presence: true, if: proc{ |c| c.activate_mailchimp_sync }
  validate :password_exists
  with_options if: proc{ |c| c.activate_free_hardware? } do |c|
    c.validates :free_hardware_label, :free_hardware_link, :free_hardware_quantity, presence: true
    c.validates :free_hardware_quantity, numericality: { only_integer: true, greater_than: 0 }, allow_blank: true
  end
  before_validation :assign_new_slug
  before_validation :cleanup_custom_registration_email
  before_validation :generate_slug, if: proc{ |c| c.slug.blank? }
  before_validation :clean_admins

  attr_accessible :new_slug, :name, :prizes_attributes, :sponsor_ids,
    :video_link, :cover_image_id, :end_date, :end_date_dummy, :avatar_id,
    :challenge_admins_attributes, :voting_end_date_dummy, :start_date_dummy,
    :pre_registration_start_date_dummy, :start_date, :pre_contest_start_date_dummy,
    :pre_contest_end_date_dummy, :winners_announced_date_dummy,
    :pre_winners_announced_date_dummy, :free_hardware_end_date_dummy,
    :categories_attributes
  attr_accessor :new_slug, :end_date_dummy, :voting_end_date_dummy, :start_date_dummy,
    :pre_registration_start_date_dummy, :pre_contest_start_date_dummy,
    :pre_contest_end_date_dummy, :winners_announced_date_dummy,
    :pre_winners_announced_date_dummy, :free_hardware_end_date_dummy

  accepts_nested_attributes_for :prizes, :challenge_admins, :categories,
    allow_destroy: true

  store :properties, accessors: []
  hstore_column :hproperties, :activate_banners, :boolean, default: true
  hstore_column :hproperties, :activate_categories, :boolean
  hstore_column :hproperties, :activate_mailchimp_sync, :boolean
  hstore_column :hproperties, :activate_pre_contest, :boolean  # legacy
  hstore_column :hproperties, :activate_free_hardware, :boolean
  hstore_column :hproperties, :activate_pre_registration, :boolean
  hstore_column :hproperties, :activate_voting, :boolean
  hstore_column :hproperties, :after_submit_idea_tweet, :string, default: 'I just submitted an idea to %{name}. You should too!'
  hstore_column :hproperties, :after_submit_entry_tweet, :string, default: 'I just submitted a project to %{name}. You should too!'
  hstore_column :hproperties, :after_registration_tweet, :string, default: 'I just registered to %{name}. You should too!'
  hstore_column :hproperties, :auto_approve, :boolean
  hstore_column :hproperties, :allow_anonymous_votes, :boolean
  hstore_column :hproperties, :custom_css, :string
  hstore_column :hproperties, :custom_registration_email, :string
  hstore_column :hproperties, :custom_status, :string
  hstore_column :hproperties, :custom_tweet, :string
  hstore_column :hproperties, :description, :string
  hstore_column :hproperties, :disable_pre_contest_winners, :boolean  # legacy
  hstore_column :hproperties, :disable_projects_phase, :boolean
  hstore_column :hproperties, :disable_projects_tab, :boolean
  hstore_column :hproperties, :disable_registration, :boolean
  hstore_column :hproperties, :eligibility, :string
  hstore_column :hproperties, :enter_button_text, :string, default: 'Submit my final entry'
  hstore_column :hproperties, :free_hardware_label, :string
  hstore_column :hproperties, :free_hardware_link, :string
  hstore_column :hproperties, :free_hardware_quantity, :integer
  hstore_column :hproperties, :free_hardware_end_date, :datetime
  hstore_column :hproperties, :how_to_enter, :string
  # hstore_column :hproperties, :idea_survey_link, :string
  hstore_column :hproperties, :judging_criteria, :string
  hstore_column :hproperties, :mailchimp_api_key, :string
  hstore_column :hproperties, :mailchimp_list_id, :string
  hstore_column :hproperties, :mailchimp_last_synced_at, :datetime
  hstore_column :hproperties, :multiple_entries, :boolean
  hstore_column :hproperties, :password_protect, :boolean
  hstore_column :hproperties, :password, :string
  hstore_column :hproperties, :pre_contest_awarded, :boolean  # legacy
  hstore_column :hproperties, :pre_contest_end_date, :datetime  # legacy
  hstore_column :hproperties, :pre_contest_label, :string, default: 'Pre-contest'  # legacy
  hstore_column :hproperties, :pre_contest_start_date, :datetime  # legacy
  hstore_column :hproperties, :pre_registration_start_date, :datetime
  hstore_column :hproperties, :pre_winners_announced_date, :datetime  # legacy
  hstore_column :hproperties, :project_ideas, :boolean
  hstore_column :hproperties, :ready, :boolean
  hstore_column :hproperties, :requirements, :string
  hstore_column :hproperties, :rules, :string
  hstore_column :hproperties, :teaser, :string
  hstore_column :hproperties, :token_tags, :hash
  hstore_column :hproperties, :sponsor_link, :string
  hstore_column :hproperties, :sponsor_name, :string
  hstore_column :hproperties, :voting_start, :string, default: :end
  hstore_column :hproperties, :voting_end_date, :datetime, default: proc{|c| c.end_date ? c.end_date + 7.days : nil }
  hstore_column :hproperties, :winners_announced_date, :datetime
  hstore_column :hproperties, :winners_label, :string, default: 'Winners'

  counters_column :hcounters_cache
  has_counter :ideas, 'activate_free_hardware? ? ideas.count : ideas.old_approved.count'
  has_counter :projects, 'projects.valid.count'
  has_counter :registrations, 'registrations.count'

  is_impressionable counter_cache: true, unique: :session_hash

  workflow do
    state :new do
      event :pre_launch, transitions_to: :pre_registration
      event :launch_contest, transitions_to: :in_progress
    end
    state :pre_registration do
      event :launch_contest, transitions_to: :in_progress
      event :take_offline, transitions_to: :new
    end
    state :in_progress do
      event :cancel, transitions_to: :canceled
      event :end, transitions_to: :judging
      event :pause, transitions_to: :paused
      event :take_offline, transitions_to: :new
    end
    state :canceled
    state :paused do
      event :restart, transitions_to: :in_progress
    end
    state :judging do
      event :cancel, transitions_to: :canceled
      event :mark_as_judged, transitions_to: :judged
      event :reinitialize, transitions_to: :new
    end
    state :judged
    after_transition do |from, to, triggering_event, *event_args|
      notify_observers(:"after_#{triggering_event}")
    end
  end

  def self.active
    where(workflow_state: REGISTRATION_OPEN_STATES)
  end

  def self.coming
    where(workflow_state: :pre_registration)
  end

  def self.ends_first
    order(end_date: :asc)
  end

  def self.ends_last
    order(end_date: :desc)
  end

  def self.past
    where workflow_state: PAST_STATES
  end

  def self.publyc
    where "CAST(challenges.hproperties -> 'password_protect' AS BOOLEAN) = ? OR CAST(challenges.hproperties -> 'password_protect' AS BOOLEAN) IS NULL", false
  end

  def self.ready
    where "CAST(challenges.hproperties -> 'ready' AS BOOLEAN) = ?", true
  end

  def self.starts_first
    order(start_date: :asc)
  end

  def allow_multiple_entries?
    multiple_entries
  end

  def auto_approve?
    auto_approve
  end

  def assign_new_slug
    @old_slug = slug
    self.slug = new_slug
  end

  def avatar_id=(val)
    self.avatar = Avatar.find_by_id(val)
  end

  def cover_image_id=(val)
    self.cover_image = CoverImage.find_by_id(val)
  end

  def dates
    return @dates if @dates

    @dates = []

    if activate_pre_registration?
      @dates << { date: pre_registration_date, label: 'Registration opens' } if pre_registration_start_date
    end

    # legacy
    if activate_pre_contest?
      @dates << { date: pre_contest_start_date, label: "#{pre_contest_label} opens" } if pre_contest_start_date
      @dates << { date: pre_contest_end_date, label: "#{pre_contest_label} closes" } if pre_contest_end_date
      @dates << { date: pre_winners_announced_date, format: :short_date, label: "#{pre_contest_label} winners announced by" } if pre_winners_announced_date and not disable_pre_contest_winners?
    end

    if activate_free_hardware?
      @dates << { date: free_hardware_end_date, label: "Deadline to apply for free hardware" } if free_hardware_end_date
    end

    unless disable_projects_phase?
      @dates << { date: start_date, label: 'Project submissions open' } if start_date
      @dates << { date: end_date, label: 'Project submissions close' } if end_date
      @dates << { date: winners_announced_date, format: :short_date, label: "#{winners_label} announced by" } if winners_announced_date
    end

    @dates = @dates.sort_by{|v| v[:date] }  # sort

    @dates
  end

  def disable_projects_tab?
    disable_projects_tab
  end

  def display_banners?
    platform and activate_banners and !password_protect?
  end

  def ended?
    end_date and Time.now > end_date
  end

  def end_date=(val)
    begin
      date = val.to_datetime
      write_attribute :end_date, date
    rescue
    end
  end

  def end_date_dummy
    end_date.in_time_zone(PDT_TIME_ZONE).strftime("%m/%d/%Y %l:%M %P") if end_date
  end

  def free_hardware_applications_open?
    open_for_submissions? and activate_free_hardware? and (free_hardware_end_date.blank? or free_hardware_end_date > Time.now)
  end

  def generate_slug
    return if name.blank?

    slug = name.gsub(/[^a-zA-Z0-9\-_]/, '-').gsub(/(\-)+$/, '').gsub(/^(\-)+/, '').gsub(/(\-){2,}/, '-').downcase

    # make sure it doesn't exist
    if result = self.class.where(slug: slug).first
      return if self == result
      # if it exists add a 1 and increment it if necessary
      slug += '1'
      while self.class.where(slug: slug).first
        slug.gsub!(/([0-9]+$)/, ($1.to_i + 1).to_s)
      end
    end
    self.slug = slug
  end

  def launch_contest
    halt and return unless end_date_is_valid?

    save
  end

  def locked? session
    password_protect? and session[:challenge_keys].try(:[], id) != Digest::SHA1.hexdigest(password)
  end

  def mailchimp_setup?
    activate_mailchimp_sync and mailchimp_api_key.present? and mailchimp_list_id.present?
  end

  def new_slug
    # raise new_slug.to_s
    @new_slug ||= slug
  end

  def open_for_submissions?
    workflow_state.in? OPEN_SUBMISSION_STATES
  end

  def ready_for_judging?
    judging?
  end

  def registration_open?
    workflow_state.in? REGISTRATION_OPEN_STATES
  end

  def start_date=(val)
    begin
      date = val.to_datetime
      write_attribute :start_date, date
    rescue
    end
  end

  def start_date_dummy
    start_date.in_time_zone(PDT_TIME_ZONE).strftime("%m/%d/%Y %l:%M %P") if start_date
  end

  def sync_mailchimp!
    MailchimpListManager.new(mailchimp_api_key, mailchimp_list_id).add((registrants + participants.reorder('')).uniq)
    update_attribute :mailchimp_last_synced_at, Time.now
  end

  def unlock try_password
    Digest::SHA1.hexdigest(password) if password.present? and password == try_password
  end

  def video
    return unless video_link.present?

    @video ||= Embed.new url: video_link
  end

  def voting_end_date_dummy
    voting_end_date ? voting_end_date.in_time_zone(PDT_TIME_ZONE).strftime("%m/%d/%Y %l:%M %P") : Time.now.strftime("%m/%d/%Y %l:%M %P")
  end

  def pre_registration_start_date_dummy
    pre_registration_start_date ? pre_registration_start_date.in_time_zone(PDT_TIME_ZONE).strftime("%m/%d/%Y %l:%M %P") : Time.now.strftime("%m/%d/%Y %l:%M %P")
  end

  def free_hardware_end_date_dummy
    free_hardware_end_date ? free_hardware_end_date.in_time_zone(PDT_TIME_ZONE).strftime("%m/%d/%Y %l:%M %P") : Time.now.strftime("%m/%d/%Y %l:%M %P")
  end

  def winners_announced_date_dummy
    winners_announced_date ? winners_announced_date.in_time_zone(PDT_TIME_ZONE).strftime("%m/%d/%Y %l:%M %P") : Time.now.strftime("%m/%d/%Y %l:%M %P")
  end

  def voting_active?
    activate_voting and (voting_start == :now or end_date and end_date < Time.now) and voting_end_date and voting_end_date > Time.now
  end

  private
    def clean_admins
      challenge_admins.each do |admin|
        challenge_admins.delete(admin) if admin.new_record? and admin.user.nil?
      end
    end

    # cleanup Adam's autofill
    def cleanup_custom_registration_email
      self.custom_registration_email = nil if custom_registration_email.try(:strip) == 'adamtben@outlook.com' or custom_registration_email.try(:strip) == 'adam@hackster.io'
    end

    def end_date_is_valid?
      errors.add :end_date_dummy, 'is required' and return unless end_date
      errors.add :end_date_dummy, 'must be at least 5 days in the future' and return if end_date < 5.days.from_now
      true
    end

    def password_exists
      errors.add :password, 'is required when password protection is enabled' if password_protect? and password.blank?
    end
end
