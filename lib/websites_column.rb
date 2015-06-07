module WebsitesColumn
  module ClassMethods
    def add_websites *websites
      websites.each do |website|
        hstore_column @@websites_column, "#{website}_link", :string
      end
    end

    def has_websites store_attribute, *websites
      @@websites_column = store_attribute
      add_websites websites
    end
  end

  def self.included base
    base.send :extend, ClassMethods
  end
end