class List < Collection
  include Checklist

  hstore_column :hproperties, :enable_comments, :boolean
  hstore_column :hproperties, :hide_curators, :boolean

  add_checklist :name, 'Set a name', 'name.present?', goto: 'edit_group_path(@group)', group: :get_started
  add_checklist :short_description, 'Write a short description', 'mini_resume.present?', goto: 'edit_group_path(@group)', group: :get_started
  add_checklist :cover_image, 'Upload a cover image', 'cover_image.present?', goto: 'edit_group_path(@group)', group: :get_started
  add_checklist :first_project, 'Add your first project', 'projects_count >= 1', goto: '"http://hackster.uservoice.com/knowledgebase/articles/622497"', group: :get_started

  def self.curators_not_hidden
    where "NOT defined(groups.hproperties, 'hide_curators') OR CAST(groups.hproperties -> 'hide_curators' AS BOOLEAN) = ?", false
  end

  def to_indexed_json
    super.merge!({
      curators: active_members.joins(:user).map{|m|
        u = m.user
        {
          id: u.id,
          name: u.name,
        }
      }
    })
  end

  def generate_user_name
    super

    if user_name and user_name.length < 3
      self.user_name += '_' * (3 - user_name.length)
    end
  end

  protected
    def user_name_is_unique
      return unless new_user_name.present?

      list = self.class.where("LOWER(groups.user_name) = ?", new_user_name.downcase).where.not(id: id).first
      errors.add :new_user_name, 'is already taken' if list
    end
end