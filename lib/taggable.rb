module Taggable
  module ClassMethods
    def taggable *tags
      tags.each do |tag_type|
        attr_accessible :"#{tag_type}_string", :"#{tag_type}_array"
        has_many tag_type, -> { order(name: :asc) }, as: :taggable, dependent: :destroy

        if "#{tag_type}_string".in? self.column_names
          before_save :"format_#{tag_type}_string", if: lambda {|m| m.send("#{tag_type}_string_changed?")}
          after_save :"save_#{tag_type}", if: lambda {|m| m.send("#{tag_type}_string_changed?")}
          self.send :define_method, "#{tag_type}_cached" do
            eval "
              #{tag_type}_string.present? ? #{tag_type}_string.split(',').map{ |s| s.strip } : []
            "
          end
          self.send :define_method, "#{tag_type}_array" do
            eval "#{tag_type}_cached"
          end
          self.send :define_method, "#{tag_type}_array=" do |val|
            eval "
              self.#{tag_type}_string = val.select{|v| v.present?}.join(',')
            "
          end
          self.send :define_method, "#{tag_type}_string_from_tags" do
            eval "
              self.#{tag_type}_string = #{tag_type}.pluck(:name).join(',')
            "
          end
          self.send :define_method, "format_#{tag_type}_string" do
            eval "
              tags = #{tag_type}_string.split(',')
              self.#{tag_type}_string = tags.map{|t| t.strip }.sort.join(', ')
            "
          end
        else
          after_save :"save_#{tag_type}"
          self.send :define_method, "#{tag_type}_string" do
            eval "
              @#{tag_type}_string ||= #{tag_type}.order(:name).pluck(:name).join(', ')
            "
          end
          self.send :define_method, "#{tag_type}_string=" do |val|
            eval "
              @#{tag_type}_string_was = #{tag_type}_string
              @#{tag_type}_string = val
            "
          end
          self.send :define_method, "#{tag_type}_string_was" do
            eval "
              @#{tag_type}_string_was ||= #{tag_type}_string
            "
          end
          self.send :define_method, "#{tag_type}_string_changed?" do
            eval "
              #{tag_type}_string_was != #{tag_type}_string
            "
          end
        end

        self.send :define_method, "save_#{tag_type}" do
          eval "
            tags = #{tag_type}_string.split(',').map{ |s| s.strip }
            existing = #{tag_type}.pluck(:name)
            (tags - existing).each do |tag|
              #{tag_type}.create(name: tag) if tag.present?
            end
            deleted = existing - tags
            #{tag_type}.where('tags.name IN (?)', deleted).destroy_all if deleted.any?
          "
        end
      end
    end
  end

  module InstanceMethods

  end

  def self.included base
    base.send :include, InstanceMethods
    base.send :extend, ClassMethods
  end
end