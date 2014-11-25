class Admin::BadgesController < Admin::BaseController
  before_filter :load_badge, only: [:edit, :update, :destroy]

  def index
    title "Admin / Badges - #{safe_page_params}"
    @fields = {
      'created_at' => 'awarded_badges.created_at',
      'code' => 'awarded_badges.badge_code',
    }

    params[:sort_by] ||= 'created_at'

    @badges = filter_for AwardedBadge, @fields
  end

  def new
    @badge = AwardedBadge.new params[:awarded_badge]
  end

  def create
    @badge = AwardedBadge.new(params[:awarded_badge])
    @badge.awardee_type = Rewardino.user_model.to_s

    if @badge.save
      redirect_to admin_badges_path, :notice => 'New badge created'
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @badge.update_attributes(params[:awarded_badge])
      redirect_to admin_badges_path, :notice => 'Badge successfuly updated'
    else
      render :edit
    end
  end

  def destroy
    @badge.destroy
    redirect_to admin_badges_path, :notice => 'Badge successfuly deleted'
  end

  private
    def load_badge
      @badge = AwardedBadge.find(params[:id])
    end
end