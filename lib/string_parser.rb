module StringParser
  module ClassMethods
    # make these methods return true or false instead of '1' or '0' or nil
    def parse_as_booleans store_attr, *attrs
      attrs.each do |boolean|
        define_method boolean do
          send(store_attr)[boolean] == '1' or send(store_attr)[boolean] == true or send(store_attr)[boolean] == 'true'
        end
      end
    end

    # make these methods return floats instead of strings
    def parse_as_floats store_attr, *attrs
      attrs.each do |float|
        define_method float do
          send(store_attr)[float] ? send(store_attr)[float].to_f : nil
        end
      end
    end

    # make these methods return integers instead of strings
    def parse_as_integers store_attr, *attrs
      attrs.each do |integer|
        define_method integer do
          send(store_attr)[integer] ? send(store_attr)[integer].to_i : nil
        end
      end
    end

    # make these methods return times instead of strings
    def parse_as_times store_attr, *attrs
      attrs.each do |time|
        define_method time do
          send(store_attr)[time] ? send(store_attr)[time].to_time : nil
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