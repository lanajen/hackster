module SetChangesForStoredAttributes
  module ClassMethods

    def set_changes_for_stored_attributes store_attribute
      self.stored_attributes[store_attribute.to_sym].each do |attr|

        self.send :define_method, "#{attr}" do
          eval "
            @#{attr} ||= read_store_attribute(:#{store_attribute}, '#{attr}')
          "
        end

        self.send :define_method, "#{attr}=" do |val|
          eval "
            @#{attr}_was = @#{attr}
            @#{attr} = val
            attribute_will_change! :#{attr} if @#{attr}_was != @#{attr}
            write_store_attribute(:#{store_attribute}, '#{attr}', val)
          "
        end

        self.send :define_method, "#{attr}_changed?" do
          eval "
            #{attr}_was != #{attr}
          "
        end

        self.send :define_method, "#{attr}_was" do
          eval "
            @#{attr}_was ||= #{attr}
          "
        end
      end
    end
  end

  def self.included base
    base.send :extend, ClassMethods
  end
end