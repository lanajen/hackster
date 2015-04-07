class Tableless < ActiveRecord::Base

  def self.column(name, sql_type = nil, default = nil, null = true)
    cast_type = "ActiveRecord::Type::#{sql_type.to_s.camelize}".constantize.new
    columns << ActiveRecord::ConnectionAdapters::Column.new( name.to_s, default, cast_type, null )
  end

  def self.columns()
    @columns ||= [];
  end

  def self.columns_hash
    h = {}
    for c in self.columns
      h[c.name] = c
    end
    h
  end

  def self.column_defaults
    Hash[self.columns.map{ |col|
      [col.name, col.default]
    }]
  end

  def self.descends_from_active_record?
    true
  end

  def persisted?
    false
  end

  # override the save method to prevent exceptions
  def save opts={}
    opts[:validate] ? valid? : true
  end
end