class ImagesController < ApplicationController

  def create
    @image = Image.new params.select{|k,v| k.in? %w(file caption title remote_file_url) }
    @image.attachable_id = 0
    @image.attachable_type = 'Orphan'

    if @image.save
      render json: @image, status: :ok
    else
      render json: @image.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @image = Image.find params[:id]
    @image.destroy
    render status: :ok
  end
end