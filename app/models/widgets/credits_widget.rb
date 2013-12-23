class CreditsWidget < Widget
  include TablelessAssociation
  has_many_tableless :credit_lines

  def self.model_name
    Widget.model_name
  end
end
