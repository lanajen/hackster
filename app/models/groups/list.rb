class List < Collection
  include Checklist

  hstore_column :hproperties, :enable_comments, :boolean

  add_checklist :name, 'Set a name', 'name.present?', goto: 'edit_group_path(@group)', group: :get_started
  add_checklist :short_description, 'Write a short description', 'mini_resume.present?', goto: 'edit_group_path(@group)', group: :get_started
  add_checklist :cover_image, 'Upload a cover image', 'cover_image.present?', goto: 'edit_group_path(@group)', group: :get_started
  add_checklist :first_project, 'Add your first project', 'projects_count >= 1', goto: '"#{url_for(@group)}/projects/new"', group: :get_started

  def generate_user_name
    super

    if user_name and user_name.length < 3
      self.user_name += '_' * (3 - user_name.length)
    end
  end
end