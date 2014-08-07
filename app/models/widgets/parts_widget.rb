class PartsWidget < Widget

  def self.model_name
    Widget.model_name
  end

  has_many :parts, -> { order position: :asc }, as: :partable

  define_attributes [:parts_count, :total_cost]

  attr_accessible :parts_attributes
  accepts_nested_attributes_for :parts, allow_destroy: true
  after_save :compute_total_cost, unless: :dont_compute_cost?

  def default_label
    'Bill of materials'
  end

  def to_error
    _errors = errors.messages
    parts.each_with_index do |p, i|
      p.errors.messages.each do |name, msg|
        _errors["[parts_attributes][#{i}][#{name}]"] = msg[0]
      end if p.errors.any?
    end
    _errors
  end

  def to_text
    "<div contenteditable='false' class='embed-frame' data-type='widget' data-widget-id='#{id}' data-caption=''></div>"
  end

  def to_tracker
    super.merge({
      parts_count: parts_count,
      total_cost: total_cost,
    })
  end

  private

    def dont_compute_cost?
      @dont_compute_cost
    end

    def compute_total_cost
      # Octopart.match parts.select{ |p| p.changed? }  # only changed parts
      total = 0
      parts.each{ |p| total += p.total_cost || 0 }
      self.total_cost = total.round(4)
      @dont_compute_cost = true
      save
    end
end
