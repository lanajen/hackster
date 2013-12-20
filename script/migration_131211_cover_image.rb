Avatar.where(attachable_type: 'Project').update_all(type: 'CoverImage')
CoverImage.order(:id).each do |i|
  puts i.file_url
  i.skip_file_check!
  begin
    i.file.recreate_versions!
  rescue => e
    puts "error for #{i.file_url}"
    puts e
  end
end