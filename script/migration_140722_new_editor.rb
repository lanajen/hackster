CodeWidget.all.each{|c| if c.language.in? %w(c cpp); c.language = 'c_cpp'; c.save; end  }
Project.where.not(external: true).each{|p| p.generate_description_from_widgets; p.last_edited_at = p.created_at; p.save }
BuyWidget.all.each{|b| p=b.project; p.buy_link = b.link; p.save }
BlogPost.update_all(draft: false)
Widget.update_all("widgetable_id = project_id")
# TODO: manually aggregate credit widgets for projects that have > 1
# TODO2: manually migrate blog posts to make sure their media is displayed correctly
User.index.delete
User.index_all
Project.index_all
Platform.index_all