# 80028 80311 80317 80319 80322 80326 80330 80332 80371 80339
# '80028','80311','80317','80319','80322','80326','80332','80330'

users = User.where(id: %w(80028 80311 80317 80319 80322 80326 80330 80332 80371))

# users.joins(:projects).pluck("projects.id")

puts "id    | name         | email       | city       | country       | sign_up_ip      | sign_in_ip      "
users.each do |user|
  puts "#{user.id}    | #{user.full_name}         | #{user.email}       | #{user.city}       | #{user.country}       | #{user.current_sign_in_ip}      | #{user.last_sign_in_ip}      "
end;nil

User.where(id: %w(80028 80311 80317 80319 80322 80326 80330 80332 80371 80339)).each{|p| p.update_attribute :private, true }


Project.joins(:users).where("users.id in (?)", %w(80028 80311 80317 80319 80322 80326 80330 80332 80371 80339)).each{|p| p.destroy }

Comment.joins(:user).where("users.id in (?)", %w(80028 80311 80317 80319 80322 80326 80330 80332 80371)).each{|p| puts p.body }


download/watch free movie/tv show