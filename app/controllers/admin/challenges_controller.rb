class Admin::ChallengesController < Admin::BaseController
  def index
    title "Admin / Challenges - #{safe_page_params}"
    @fields = {
      'created_at' => 'challenges.created_at',
      'name' => 'challenges.name',
      'slug' => 'challenges.slug',
    }

    params[:sort_by] ||= 'created_at'

    @challenges = filter_for Challenge, @fields
  end

  def new
    @challenge = Challenge.new(params[:challenge])
  end

  def create
    @challenge = Challenge.new(params[:challenge])

    if @challenge.save
      redirect_to edit_challenge_path(@challenge), :notice => 'New challenge created'
    else
      render :new
    end
  end

  def edit
    @challenge = Challenge.find(params[:id])
  end

  def update
    @challenge = Challenge.find(params[:id])

    if @challenge.update_attributes(params[:challenge])
      redirect_to admin_challenges_path, :notice => 'Challenge successfuly updated'
    else
      render :edit
    end
  end

  def destroy
    @challenge = Challenge.find(params[:id])
    @challenge.destroy
    redirect_to admin_challenges_path, :notice => 'Challenge successfuly deleted'
  end
end