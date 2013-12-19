class FilesController < ApplicationController

  def create
    render text: 'bad', status: :unprocessable_entity and return unless params[:file_type] and params[:file_type].in? %w(avatar image cover_image document)

    @file = params[:file_type].classify.constantize.new params.select{|k,v| k.in? %w(file caption title remote_file_url) }
    @file.attachable_id = 0
    @file.attachable_type = 'Orphan'

    if @file.save
      render json: @file, status: :ok
    else
      render json: @file.errors, status: :unprocessable_entity
    end
  end

  # def destroy
  #   @file = Image.find params[:id]
  #   @file.destroy
  #   render status: :ok
  # end
end