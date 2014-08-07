class StepByStepWidget < Widget
  include TablelessAssociation
  has_many_tableless :steps, order: :position

  def self.model_name
    Widget.model_name
  end

  def to_text
    out = "<h3>#{name}</h3>"

    steps.each_with_index.map do |step, i|
      out << "<h4>Step #{i+1}: #{step.title}</h4>"
      out << step.details.strip.split(/\r\n/).map { |p| p.present? ? "<p>#{p}</p>" : "<br>" }.join('')
      out
    end.join('')

    out
  end
end
