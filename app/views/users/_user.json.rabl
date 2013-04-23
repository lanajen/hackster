attributes :id, :user_name, :name, :created_at, :updated_at, :mini_resume

node do |user|
	{
		:created_at_formatted => user.created_at.strftime("%m/%d/%Y"),
		:updated_at_formatted => time_ago_in_words(user.updated_at),
    avatar_mini: user.decorate.avatar(:mini),
    profile_link: url_for(user),
	}
end