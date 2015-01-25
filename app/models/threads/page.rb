class Page < Post
  validates :slug, format: { with: /\A[a-z0-9\-]+\z/, message: "only accepts lower case letters, digits and the symbol -." }
  attr_accessible :slug
  before_save :generate_slug, if: proc{|p| p.slug.blank? }

  private
    def generate_slug
      return if title.blank? or threadable.blank?

      slug = title.gsub(/[^a-zA-Z0-9\-_]/, '-').gsub(/(\-)+$/, '').gsub(/^(\-)+/, '').gsub(/(\-){2,}/, '-').downcase[0..20]

      # make sure it doesn't exist
      if result = threadable.pages.where(slug: slug).first
        puts "#{self.inspect}"
        puts "#{result.inspect}"
        return if self == result
        # if it exists add a 1 and increment it if necessary
        slug += '2'
        while threadable.pages.where(slug: slug).first
          slug.gsub!(/([0-9]+$)/, ($1.to_i + 1).to_s)
        end
      end
      self.slug = slug
    end
end