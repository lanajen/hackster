class Api::V1::FollowersController < Api::V1::BaseController

  def index
    init_following = { user: [], group: [], project: [], part: [] }
    @following = if user_signed_in?
      current_user.follow_relations.select(:followable_id, :followable_type).inject(init_following) do |h, f| 
        case f.followable_type
        when 'User'
          h[:user] << f.followable_id
        when 'Group' 
          h[:group] << f.followable_id
        when 'Project'
          h[:project] << f.followable_id
        when 'Part'
          h[:part] << f.followable_id
        end
        h
      end
    else
      init_following
    end
  end

end