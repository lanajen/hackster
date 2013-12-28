class Admin::PagesController < Admin::BaseController
  include FilterHelper

  def analytics
    @project_count = Project.live.count
    @comment_count = Comment.count
    @like_count = Favorite.count
    @user_count = User.where('invitation_token IS NULL').count

    @top_users = {}
    User.all.each do |u|
      @top_users[u] = u.live_projects_count
    end
    @top_users = @top_users.reject!{ |k,v| v.nil? }.sort_by{ |k,v| -v }[0..9]
    @new_invites = InviteRequest.group("DATE_TRUNC('week', created_at)").count.sort_by{|k,v| k}
    # @new_users = User.where('invitation_accepted_at IS NOT NULL').group("DATE_TRUNC('week', invitation_accepted_at)").count.sort_by{|k,v| k}
  end

  def logs
    redirect_to admin_logs_path(page: (LogLine.count.to_f / LogLine.per_page).ceil) unless params[:page]

    title "Admin > Logs - #{params[:page]}"

    @fields = {
      'created_at' => 'log_lines.created_at',
      'log_type' => 'log_lines.log_type',
      'source' => 'log_lines.source',
    }

    params[:sort_order] ||= 'ASC'

    @log_lines = filter_for LogLine, @fields
    @log_lines = LogLine.order(:created_at).paginate(page: params[:page])
  end

  def root
  end
end
