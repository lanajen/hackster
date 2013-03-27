class PublicationsController < ApplicationController
  before_filter :authenticate_user!, except: [:index, :show]
  load_and_authorize_resource
  skip_load_resource only: [:create]

  # GET /publications
  # GET /publications.json
  def index
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @publications }
    end
  end

  # GET /publications/1
  # GET /publications/1.json
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @publication }
    end
  end

  # GET /publications/new
  # GET /publications/new.json
  def new
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @publication }
    end
  end

  # GET /publications/1/edit
  def edit
  end

  # POST /publications
  # POST /publications.json
  def create
    @publication = current_user.publications.new(params[:publication])

    respond_to do |format|
      if @publication.save
        format.html { redirect_to @publication.user, notice: 'Publication was successfully created.' }
        format.json { render json: @publication, status: :created, location: @publication }
      else
        format.html { render action: "new" }
        format.json { render json: @publication.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /publications/1
  # PUT /publications/1.json
  def update
    respond_to do |format|
      if @publication.update_attributes(params[:publication])
        format.html { redirect_to @publication.user, notice: 'Publication was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @publication.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /publications/1
  # DELETE /publications/1.json
  def destroy
    @publication.destroy

    respond_to do |format|
      format.html { redirect_to @publication.user }
      format.json { head :no_content }
    end
  end
end