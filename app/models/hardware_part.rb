class HardwarePart < Part
  def self.model_name
    Part.model_name
  end

  def identifier
    'hardware'
  end
end