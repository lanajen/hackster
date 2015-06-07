module WebsitesColumn
  module ClassMethods
    def websites_column store_attribute
      @@websites_column = store_attribute
    end

    def has_websites *websites
      websites.each do |website|
        hstore_column @@websites_column, "#{website}_link", :string
      end
    end
  end

  def self.included base
    base.send :extend, ClassMethods
  end
end