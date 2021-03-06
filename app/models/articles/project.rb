class Project < BaseProject
  PUBLIC_CONTENT_TYPES = {
    'Getting started guide' => :getting_started,
    'Protip' => :protip,
    'Showcase (no or partial instructions)' => :showcase,
    'Teardown/Unboxing' => :teardown,
    'Tutorial (complete instructions)' => :tutorial,
    'Work in progress' => :wip,
  }.freeze
  PRIVATE_CONTENT_TYPES = {
    'Video' => :video,
    'Workshop' => :workshop,
  }.freeze
  CONTENT_TYPES = PUBLIC_CONTENT_TYPES.merge(PRIVATE_CONTENT_TYPES).freeze
  CONTENT_TYPES_TO_HUMAN = {
    showcase: 'Project showcase',
    tutorial: 'Project tutorial',
    wip: 'Project in progress',
    workshop: 'Workshop',
    video: 'Video tutorial',
  }.freeze
  DEFAULT_CONTENT_TYPE = :tutorial

  has_many :awards
  has_many :build_logs, as: :threadable, dependent: :destroy
  has_many :challenge_entries, dependent: :destroy
  has_many :events, -> { where("groups.type = 'Event'") }, through: :project_collections, source_type: 'Group', source: :collectable
  has_many :hacker_spaces, -> { where("groups.type = 'HackerSpace'") }, through: :project_collections, source_type: 'Group', source: :collectable
  has_many :issues, as: :threadable, dependent: :destroy
  has_many :replicated_users, through: :follow_relations, source: :user

  validates :cover_image, :name, :one_liner, :difficulty, :content_type, :product_tags_array, presence: { message: 'is required for publication' },  if: proc{|p| p.workflow_state_changed? and p.workflow_state_was == 'unpublished' and p.workflow_state.in? %w(pending_review approved) }

  has_counter :build_logs, 'build_logs.published.count'
  has_counter :issues, 'issues.where(type: "Issue").count'
  has_counter :replications, 'replicated_users.count'

  hstore_column :hproperties, :private_issues, :boolean
  hstore_column :hproperties, :private_logs, :boolean

  add_checklist :description, 'Story', 'Sanitize.clean(description).try(:strip).present? or story_json.present?'
  add_checklist :hardware_parts, 'Components', 'hardware_parts.any?'
  add_checklist :schematics, 'Schematics', 'widgets.where(type: %w(SchematicWidget SchematicFileWidget)).any?'
  add_checklist :code, 'Code', 'widgets.where(type: %w(CodeWidget CodeRepoWidget)).any?'

  add_checklist :name, 'Name', 'name.present? and !has_default_name?', group: :april_2016
  add_checklist :one_liner, 'Elevator pitch', nil, group: :april_2016
  add_checklist :cover_image, 'Cover image', 'cover_image and cover_image.file_url', group: :april_2016
  add_checklist :description, 'Story', 'Sanitize.clean(description).try(:strip).present? or story_json.present?', group: :april_2016
  add_checklist :hardware_parts, 'Components and apps', 'hardware_parts.any? or software_parts.any?', group: :april_2016
  add_checklist :schematics, 'Schematics', 'widgets.where(type: %w(SchematicWidget SchematicFileWidget)).any?', group: :april_2016
  add_checklist :code, 'Code', 'widgets.where(type: %w(CodeWidget CodeRepoWidget)).any?', group: :april_2016

  def self.model_name
    BaseArticle.model_name
  end

  def all_issues
    (issues + Issue.where(threadable_type: 'Widget').where('threadable_id IN (?)', widgets.pluck('widgets.id'))).sort_by{ |t| t.created_at }
  end

  def identifier
    'project'
  end

  %w(event hacker_space).each do |type|
    define_method type do
      get_collection type
    end

    define_method "#{type}=" do |val|
      set_collection val, type
    end

    define_method "#{type}_id" do
      get_collection_id type
    end

    define_method "#{type}_id=" do |val|
      set_collection_id val, type
    end
  end

  def has_assignment?
    assignment.present?
  end

  def has_no_assignment?
    assignment.nil?
  end

  def is_idea?
    workflow_state == 'idea'
  end

  def locked?
    locked
  end

  def mark_as_idea
    is_idea?
  end

  def mark_as_idea=(val)
    self.workflow_state = (val.in?([1, '1', 't']) ? 'idea' : nil)
  end

  def unlocked?
    !locked?
  end
end
