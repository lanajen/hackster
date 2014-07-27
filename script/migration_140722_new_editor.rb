CodeWidget.all.each{|c| c.language = 'c_cpp' && c.save if c.language.in? %w(c cpp) }
Project.all.each{|p| p.generate_description_from_widgets; p.save }
BuyWidget.all.each{|b| p=b.project; p.buy_link = b.link; p.save }
# TODO: manually aggregate credit widgets for projects that have > 1