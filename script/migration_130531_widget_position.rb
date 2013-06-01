Project.all.each do |p|
  half = (p.widgets.size.to_f / 2).ceil
  j = 1
  p.widgets.each_with_index do |w,i|
    if i < half
      w.position = "1.#{j}"
    else
      w.position = "2.#{j}"
    end
    if i+1 == half
      j = 1
    else
      j += 1
    end
    w.save
  end
end