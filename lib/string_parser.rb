module StringParser
  module ClassMethods
    # make these methods return true or false instead of '1' or '0' or nil
    def parse_as_booleans store_attr, *attrs
      attrs.each do |boolean|
        define_method boolean do
          send(store_attr).try(:[], boolean.to_s) == '1' or send(store_attr)[boolean.to_s] == true or send(store_attr)[boolean.to_s] == 'true'
        end
      end
    end

    # make these methods return floats instead of strings
    def parse_as_floats store_attr, *attrs
      attrs.each do |float|
        define_method float do
          send(store_attr).try(:[], float.to_s) ? send(store_attr)[float.to_s].to_f : nil
        end
      end
    end

    # make these methods return integers instead of strings
    def parse_as_integers store_attr, *attrs
      attrs.each do |integer|
        define_method integer do
          send(store_attr).try(:[], integer.to_s) ? send(store_attr)[integer.to_s].to_i : nil
        end
      end
    end

    # make these methods return times instead of strings
    def parse_as_datetimes store_attr, *attrs
      attrs.each do |time|
        define_method time do
          send(store_attr).try(:[], time.to_s) ? Time.at(send(store_attr)[time.to_s]) : nil
        end
      end
    end
  end

  def self.included base
    base.class_eval do
      base.send :extend, ClassMethods
    end
  end
end