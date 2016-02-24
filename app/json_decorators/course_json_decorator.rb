class CourseJsonDecorator < GroupJsonDecorator
  def node
    node = super
    node.merge! hash_for(%w(course_number mini_resume))
    node[:cover_image_url] = model.decorate.cover_image(:cover_wide_mini)
    node
  end
end