class SoftwarePart < Part
  def self.model_name
    Part.model_name
  end

  def identifier
    'software'
  end
end