class PressWidget < Widget
  include TablelessAssociation
  has_many_tableless :press_articles

  def self.model_name
    Widget.model_name
  end
end
