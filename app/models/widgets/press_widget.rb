class PressWidget < Widget
  include TablelessAssociation
  has_many_tableless :press_articles

  def self.model_name
    Widget.model_name
  end

  def to_text
    if press_articles.any?
      out = "<h3>In the press</h3><ul>"
      press_articles.each do |article|
        out << "<li>"
        out << if article.link.present?
          "<a href='#{article.link}' target='_blank' rel='nofollow'>#{article.title}</a>"
        else
          article.title
        end
        out << " by #{article.publication}" if article.publication.present?
        out << " on #{article.date}" if article.date.present?
        out << "</li>"
        out
      end
      out << "</ul>"
      out
    else
      ''
    end
  end
end