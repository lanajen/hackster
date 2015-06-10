module WebsitesColumn
  module ClassMethods
    def add_websites *websites
      websites.each do |website|
        hstore_column @@websites_column, "#{website}_link", :string
      end
    end

    def has_websites store_attribute, *websites
      @@websites_column = store_attribute
      if column_for_attribute(store_attribute).type == :text
        store store_attribute, accessors: []
      end
      add_websites *websites

      self.send :define_method, :has_websites? do
        send(store_attribute).select{|k,v| v.present? }.any?
      end
    end
  end

  def self.included base
    # dependency
    base.send :include, HstoreColumn unless base.included_modules.include? HstoreColumn

    base.send :extend, ClassMethods
  end
end