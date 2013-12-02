ImageWidget.all.each do |w|
  w.images.each_with_index do |a, i|
    a.position = i+1
    a.skip_file_check!
    a.save
  end
end