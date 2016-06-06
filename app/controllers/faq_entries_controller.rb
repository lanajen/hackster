class FaqEntriesController < MainBaseController
  before_filter :authenticate_user!
  before_filter :load_challenge, except: [:destroy]
  before_filter :load_faq_entry, only: [:edit, :update, :destroy]

  def index
    title "FAQ | #{@challenge.name}"
    @faq_entries = @challenge.faq_entries.order("LOWER(threads.title) ASC")
  end

  def new
    title "New FAQ | #{@challenge.name}"
    @faq_entry = @challenge.faq_entries.new
  end

  def create
    @faq_entry = @challenge.faq_entries.new(params[:faq_entry])
    @faq_entry.user = current_user

    if @faq_entry.save
      redirect_to challenge_faq_entries_path(@challenge), notice: 'FAQ entry created.'
    else
      render 'new'
    end
  end

  def edit
    title "FAQ / Edit #{@faq_entry.title} | #{@challenge.name}"
  end

  def update
    if @faq_entry.update_attributes(params[:faq_entry])
      redirect_to challenge_faq_entries_path(@challenge), notice: 'FAQ entry updated.'
    else
      render 'edit'
    end
  end

  def destroy
    @challenge = @faq_entry.threadable
    @faq_entry.destroy

    redirect_to challenge_faq_entries_path(@challenge), notice: 'FAQ entry deleted.'
  end

  private
    def load_challenge
      @challenge = Challenge.find params[:challenge_id]
      authorize! :admin, @challenge
    end

    def load_faq_entry
      @faq_entry = FaqEntry.find params[:id]
    end
end