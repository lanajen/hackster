class BaseProject < BaseArticle
  DEFAULT_TAGS = [
    'Animals',
    'Art',
    'Audio',
    'Cars',
    'Clocks',
    'Communication',
    'Data Collection',
    'Disability Reduction',
    'Drones',
    'Embedded',
    'Energy Efficiency',
    'Entertainment System',
    'Environmental Sensing',
    'Food And Drinks',
    'Games',
    'Garden',
    'Greener Planet',
    'Health',
    'Helicopters',
    'Home Automation',
    'Human Welfare',
    'Internet Of Things',
    'Kids',
    'Lights',
    'Monitoring',
    'Music',
    'Passenger Vehicles',
    'Pets',
    'Planes',
    'Plants',
    'Recycling',
    'Remote Control',
    'Robots',
    'Security',
    'Smartwatches',
    'Smart appliances',
    'Toys',
    'Transportation',
    'Tracking',
    'Wardriving',
    'Wearables',
    'Weather',
  ]

  has_many :hardware_parts, -> { where(parts: { type: 'HardwarePart' } ) }, through: :part_joins, source: :part
  has_many :hardware_part_joins, -> { joins(:part).where(parts: { type: 'HardwarePart'}).order(:position).includes(part: { image: [], platform: :avatar }) }, as: :partable, class_name: 'PartJoin', autosave: true
  has_many :software_parts, -> { where(parts: { type: 'SoftwarePart' } ) }, through: :part_joins, source: :part
  has_many :software_part_joins, -> { joins(:part).where(parts: { type: 'SoftwarePart'}).order(:position).includes(part: { image: [], platform: :avatar }) }, as: :partable, class_name: 'PartJoin', autosave: true
  has_many :tool_part_joins, -> { joins(:part).where(parts: { type: 'ToolPart'}).order(:position).includes(part: { image: [], platform: :avatar }) }, as: :partable, class_name: 'PartJoin', autosave: true
  has_many :tool_parts, -> { where(parts: { type: 'ToolPart' } ) }, through: :part_joins, source: :part

  attr_accessible :hardware_part_joins_attributes, :tool_part_joins_attributes,
    :software_part_joins_attributes
  accepts_nested_attributes_for :hardware_part_joins, :tool_part_joins,
    :software_part_joins, allow_destroy: true

  has_counter :hardware_parts, 'hardware_parts.count'
  has_counter :software_parts, 'software_parts.count'
  has_counter :tool_parts, 'tool_parts.count'

  protected
    def delete_empty_part_ids
      (hardware_part_joins + software_part_joins + tool_part_joins).each do |part_join|
        part_join.delete if part_join.part_id.blank?
      end
    end
end