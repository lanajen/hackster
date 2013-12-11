Avatar.where(attachable_type: 'Project').update_all(type: 'CoverImage')
CoverImage.all.each do |i|
  i.skip_file_check!
  i.file.recreate_versions!
end