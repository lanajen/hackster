module WebsitesColumn
  module ClassMethods
    def add_websites *websites
      websites.each do |website|
        attribute = "#{website}_link"
        hstore_column @@websites_column, attribute, :url

        validate do |model|
          value = model.send(attribute)
          model.validate_url attribute, value if value.present?
        end

        if website == :twitter
          define_method :twitter_handle do
            TwitterHandle.new(twitter_link).handle
          end
        end
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

  module InstanceMethods
    def validate_url attribute, url
      errors.add attribute, 'is not a valid URL' unless Url.new(url).valid?
    end
  end

  def self.included base
    # dependency
    base.send :include, HstoreColumn unless base.included_modules.include? HstoreColumn
    base.send :include, InstanceMethods

    base.send :extend, ClassMethods
  end
end