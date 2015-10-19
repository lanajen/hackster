class Project < BaseProject
  PUBLIC_CONTENT_TYPES = {
    'Showcase (no or incomplete instructions)' => :showcase,
    'Tutorial (complete instructions)' => :tutorial,
  }
  PRIVATE_CONTENT_TYPES = {
    'Workshop' => :workshop,
  }
  CONTENT_TYPES = PUBLIC_CONTENT_TYPES.merge(PRIVATE_CONTENT_TYPES)
  DEFAULT_CONTENT_TYPE = :tutorial

  is_impressionable counter_cache: true, unique: :session_hash

  has_many :assignments, through: :project_collections, source: :collectable, source_type: 'Assignment'
  has_many :awards
  has_many :build_logs, as: :threadable, dependent: :destroy
  has_many :challenge_entries, dependent: :destroy
  has_many :events, -> { where("groups.type = 'Event'") }, through: :project_collections, source_type: 'Group', source: :collectable
  has_many :grades
  has_many :hacker_spaces, -> { where("groups.type = 'HackerSpace'") }, through: :project_collections, source_type: 'Group', source: :collectable
  has_many :issues, as: :threadable, dependent: :destroy
  has_many :replicated_users, through: :follow_relations, source: :user

  has_counter :build_logs, 'build_logs.published.count'
  has_counter :issues, 'issues.where(type: "Issue").count'
  has_counter :replications, 'replicated_users.count'

  hstore_column :hproperties, :private_issues, :boolean
  hstore_column :hproperties, :private_logs, :boolean

  add_checklist :description, 'Story', 'Sanitize.clean(description).try(:strip).present?'
  add_checklist :hardware_parts, 'Components', 'hardware_parts.any?'
  add_checklist :schematics, 'Schematics', 'widgets.where(type: %w(SchematicWidget SchematicFileWidget)).any?'
  add_checklist :code, 'Code', 'widgets.where(type: %w(CodeWidget CodeRepoWidget)).any?'

  def self.model_name
    BaseArticle.model_name
  end

  def all_issues
    (issues + Issue.where(threadable_type: 'Widget').where('threadable_id IN (?)', widgets.pluck('widgets.id'))).sort_by{ |t| t.created_at }
  end

  def credit_lines
    @credit_lines ||= credits_widget.try(:credit_lines) || []
  end

  def credits_widget
    @credits_widget ||= CreditsWidget.where(widgetable_id: id, widgetable_type: 'BaseArticle').first_or_create
  end

  def identifier
    'project'
  end
  # the following methods make has_many relations work has_one style
  def get_collection collection_type
    send("#{collection_type}s").first
  end

  def get_collection_id collection_type
    get_collection(collection_type).try(:id)
  end

  def set_collection_id id, collection_type
    self.send("#{collection_type}s").destroy_all
    self.send("#{collection_type}s") << collection_type.camelize.constantize.find_by_id(id) if id.to_i != 0
  end

  def set_collection collection, collection_type
    self.send("#{collection_type}s").destroy_all
    self.send("#{collection_type}s") << collection if collection
  end

  %w(assignment event hacker_space).each do |type|
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

  def wip?
    wip
  end
end