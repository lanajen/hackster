class SkillRequestsController < ApplicationController
  load_and_authorize_resource

  def index
    @skill_requests = SkillRequest.paginate(page: safe_page_params)
  end

  def show
  end

  def new
  end

  def create
    @skill_request.user = current_user

    if @skill_request.save
      redirect_to @skill_request, notice: 'Yeay! Your request has been created, now share it and wait for responses.'
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @skill_request.update_attributes params[:skill_request]
      redirect_to @skill_request, notice: 'Your request has been updated.'
    else
      render :edit
    end
  end

  def destroy
  end
end