class AddressesController < ApplicationController
  before_filter :authenticate_user!
  before_filter :load_and_authorize_entry, only: [:edit, :update, :destroy]

  def edit
  end

  def update
    if @address.update_attributes(params[:address])
      redirect_to @challenge, notice: "Thanks, you're all set! Your prize will be in your mail box soon :)"
    else
      render 'edit'
    end
  end

  private
    def load_and_authorize_entry
      @entry = ChallengeEntry.find params[:id]
      @address = @entry.address || (a=@entry.build_address; a.save(validate: false);a)
      authorize! self.action_name, @address
      @challenge = @entry.challenge
    end
end