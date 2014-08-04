CodeWidget.all.each{|c| c.language = 'c_cpp' && c.save if c.language.in? %w(c cpp) }
Project.where.not(external: true).where(description: nil).each{|p| p.generate_description_from_widgets; p.last_edited_at = p.created_at; p.save }
BuyWidget.all.each{|b| p=b.project; p.buy_link = b.link; p.save }
# TODO: manually aggregate credit widgets for projects that have > 1