class StepByStepWidget < Widget
  include TablelessAssociation
  has_many_tableless :steps, order: :position

  def self.model_name
    Widget.model_name
  end
end
