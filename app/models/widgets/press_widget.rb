class PressWidget < Widget
  attr_accessible :press_articles_attributes
  has_many :press_articles
  accepts_nested_attributes_for :press_articles
  # before_validation :validate_press_articles

  # def validate_press_articles
  #   # press_articles.each{ |a| a.valid?; raise a.errors.inspect }
  #   errors.add :press_articles, 'press articles' unless press_articles.each{ |a| a.valid? }.select{ |v| v == false }.any?
  # end

  def self.model_name
    Widget.model_name
  end

  def press_articles
    val = properties[:press_articles]
    if val.present?
      YAML::load(val).map do |attrs|
        attrs.except!(:_destroy, '_destroy')
        PressArticle.new attrs.merge(widget_id: id)
      end
    else
      []
    end
  end

  def press_articles=(val)
    raise 'type not supported' unless val.kind_of? Array

    items = []
    val.each do |item|
      case item
      when Hash
        items << item
      when PressArticle
        items << item.attributes
      end
    end

    props = properties
    props[:press_articles] = YAML::dump(items)
    self.properties = props
  end

  def press_articles_attributes=(val)
    self.press_articles = val.delete_if{ |i, attrs| attrs['_destroy'] == '1' }.map{ |k,v| v }
  end
end
