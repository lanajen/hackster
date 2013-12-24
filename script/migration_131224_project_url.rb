Team.all.each{|t| t.save }
Project.all.each{|p| p.update_slug!}