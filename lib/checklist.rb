module Checklist
  module ClassMethods
    def add_checklist name, label, condition=nil, options={}
      gconfig = checklist_config.try(:dup) || {}
      group_name = options[:group].presence || :default
      config = gconfig[group_name].try(:dup) || {}

      item = {
        label: label,
        condition: condition.presence || "#{name}.present?",
        goto: options[:goto].presence || "'#{name}'",
      }
      if options[:family]
        config[:families] ||= {}
        config[:families][options[:family]] ||= {}
        config[:families][options[:family]][options[:priority]] = item
      else
        config[name] = item
      end
      gconfig[group_name] = config
      self.checklist_config = gconfig
    end

    def add_checklist_family name, condition, options={}
      groups = options.delete(:groups)
      labels = options.delete(:labels)
      options.delete(:thresholds).each do |threshold|
        n_name = :"#{threshold}_#{name}"
        n_label = threshold.in?(labels.keys) ? labels[threshold] : labels[:n].gsub(/%\{n\}/, threshold.to_s)
        n_condition = condition.gsub('%{n}', threshold.to_s)
        n_group = threshold.in?(groups.keys) ? groups[threshold] : groups[:n]
        add_checklist n_name, n_label, n_condition, { family: name, priority: threshold, group: n_group }.merge(options)
      end
    end

    def remove_checklist name, options={}
      gconfig = checklist_config.try(:dup) || {}
      group_name = options[:group].presence || :default
      config = gconfig[group_name].try(:dup) || {}

      config = config.except! name

      gconfig[group_name] = config
      self.checklist_config = gconfig
    end
  end

  module InstanceMethods
    def checklist_completion group_name=:default
      @checklist_completion ||= {}
      @checklist_completion[group_name] ||= ((checklist_completed?(group_name) ? 1 : checklist_done(group_name).size.to_f / (checklist_done(group_name).size + checklist_todo(group_name).size)) * 100).to_i
    end

    def checklist_completed? group_name=:default
      completion = checklist_evaled[group_name].try(:[], :complete)
      completion.nil? ? true : completion
    end

    def checklist_done group_name=:default
      checklist_evaled[group_name].try(:[], :done) || []
    end

    def checklist_evaled
      return @checklist_evaled if @checklist_evaled

      @checklist_evaled ||= {}

      checklist_config.deep_dup.each do |group_name, config|
        done = []
        todo = []
        families = config.delete(:families)

        config.each do |name, item|
          if eval(item.delete(:condition))
            done << item
          else
            todo << item
          end
        end

        families.each do |family_name, thresholds|
          family_done = nil
          family_todo = nil
          thresholds.each do |threshold, item|
            if eval(item.delete(:condition))
              family_done = item
            else
              family_todo = item
              break
            end
          end
          done << family_done if family_done
          todo << family_todo if family_todo
        end if families

        @checklist_evaled[group_name] = { done: done, todo: todo, complete: todo.empty? }
      end

      @checklist_evaled
    end

    def checklist_todo group_name=:default
      checklist_evaled[group_name].try(:[], :todo) || []
    end
  end

  def self.included base
    base.send :extend, ClassMethods
    base.send :include, InstanceMethods
    base.send :class_attribute, :checklist_config, instance_writer: false
  end
end