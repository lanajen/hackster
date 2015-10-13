class Protip < Project
  is_impressionable counter_cache: true, unique: :session_hash

  add_checklist :parts, 'Products', 'parts.any?'
  remove_checklist :description
  remove_checklist :hardware_parts
  remove_checklist :schematics
  remove_checklist :code
  add_checklist :description, 'Description', 'Sanitize.clean(description).try(:strip).present?'

  def self.model_name
    Project.model_name
  end

  def identifier
    'protip'
  end
end