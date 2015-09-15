class ToolPart < Part
  def self.model_name
    Part.model_name
  end

  def identifier
    'tool'
  end
end