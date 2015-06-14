class Assignment < ActiveRecord::Base
  include HstoreColumn

  GRADING_TYPES = {
    'One grade per student' => 'individual',
    'A single grade per team' => 'group',
    'We will grade students outside of Hackster' => 'none',
  }

  belongs_to :promotion
  has_many :grades, through: :projects
  has_many :project_collections, as: :collectable
  has_many :projects, through: :project_collections
  has_one :document, as: :attachable, dependent: :destroy
  validates :promotion_id, :name, presence: true
  attr_accessible :name, :document_id, :grading_type, :graded, :private_grades,
    :disable_tweeting, :hide_all, :submit_by_date, :submit_by_date_dummy
  attr_accessor :submit_by_date_dummy

  store :properties, accessor: []
  hstore_column :properties, :disable_tweeting, :boolean
  hstore_column :properties, :hide_all, :boolean

  before_create :generate_id

  def document_id=(val)
    self.document = Document.find_by_id(val)
  end

  def graded?
    graded
  end

  def grading_activated?
    grading_type != 'none'
  end

  def past_due?
    submit_by_date and submit_by_date < Time.now
  end

  def submit_by_date=(val)
    begin
      date = val.to_datetime
      write_attribute :submit_by_date, date
    rescue
    end
  end

  def submit_by_date_dummy
    submit_by_date.strftime("%m/%d/%Y %l:%M %P") if submit_by_date
  end

  def to_csv
    out = "project_name,project_url,grade,student_names,student_emails\r\n"

    grades.each do |grade|
      out << "\"#{grade.project.name}\",\"http://hackster.io/#{grade.project.uri}\",\"#{grade.grade}\",\"#{grade.project.users.map{|u| u.name}.join(',')}\",\"#{grade.project.users.map{|u| u.email}.join(',')}\"\r\n"
    end
    out
  end

  def to_label
    "#{promotion.name} / #{name}"
  end

  private
    def generate_id
      last_id = promotion.assignments.order(:created_at).last.try(:id_for_promotion) || 0
      self.id_for_promotion = last_id + 1
    end
end
