class ChallengeWorker < BaseWorker
  def announce_pre_contest_winners id
    challenge = Challenge.find id

    challenge.ideas.where(workflow_state: %w(new approved)).each do |idea|
      idea.mark_lost!
    end
    Cashier.expire "challenge-#{challenge.id}-ideas", "challenge-#{challenge.id}-brief"
    FastlyWorker.perform_async 'purge', challenge.record_key

    NotificationCenter.notify_all :pre_contest_awarded, :challenge, id, 'pre_contest_awarded'
    challenge.ideas.won.each do |idea|
      NotificationCenter.notify_all :awarded, :challenge_idea, idea.id
    end
  end

  def do_after_judged id
    challenge = Challenge.find id

    challenge.entries.where(workflow_state: %w(new qualified)).each do |entry|
      entry.has_prize? ? entry.give_award! : entry.give_no_award!
    end
    expire_cache challenge

    NotificationCenter.notify_all :judged, :challenge, id
  end

  def generate_entries_csv challenge_id, doc_id, file_name
    challenge = Challenge.find challenge_id
    entries = challenge.entries.joins(:project, :user).includes(:prizes, user: :avatar, project: :team).order(:created_at)

    headers = ['Project name', 'Project URL', 'Project created on', 'Authors', 'Tags', 'Completion', 'Views count', 'Respects count', 'Comments count', 'Replications count', 'Entry status']
    rows = [headers]

    entries.each do |entry|
      project = entry.project
      row = []
      row << project.name
      row << "https://www.hackster.io/#{project.uri}"
      row << project.created_at
      row << project.users.map(&:name).to_sentence
      row << project.product_tags_string
      row << "#{project.checklist_completion}%"
      row << project.impressions_count
      row << project.respects_count
      row << project.comments_count
      row << project.replications_count
      row << entry.workflow_state
      rows << row
    end

    save_csv_to_file rows, doc_id, file_name
  end

  def generate_ideas_csv challenge_id, doc_id, file_name
    challenge = Challenge.find challenge_id
    ideas = challenge.ideas.order(:created_at).joins(:user).includes(:address, :image, user: :avatar)

    headers = ['Name', 'Description', 'Image URL']
    headers += challenge.challenge_idea_fields.map(&:label)
    headers += ['Submitter name', 'Submission date', 'Submission status', 'Email']
    if challenge.pre_contest_awarded?
      headers += ['Full name', 'Address line 1', 'Address line 2', 'Zip code', 'State', 'Country', 'Phone number']
    end
    rows = [headers]
    ideas.each do |idea|
      user = idea.user
      output = [idea.name, ActionController::Base.helpers.strip_tags(idea.description).gsub(/"/, '""'), idea.image.try(:imgix_url, :thumb)]
      output += challenge.challenge_idea_fields.each_with_index.map{|f, i| idea.send("cfield#{i}").try(:gsub, /"/, '""') }
      output += [user.name, idea.created_at.in_time_zone(PDT_TIME_ZONE), idea.workflow_state, user.email]
      if challenge.pre_contest_awarded?
        if idea.won? and address = idea.address
          output += [address.full_name, address.address_line1, address.address_line2, address.zip, address.state, address.country, address.phone]
        else
          output += ['', '', '', '', '', '', '']
        end
      end
      rows << output
    end

    save_csv_to_file rows, doc_id, file_name
  end

  def generate_participants_csv challenge_id, doc_id, file_name
    challenge = Challenge.find challenge_id
    registrations = challenge.registrations.joins(:user).includes(:user).order("users.full_name ASC")

    headers = ['Name', 'Email', 'Registration date']
    rows = [headers]
    registrations.each do |registration|
      user = registration.user
      rows << [user.name, user.email, registration.created_at.in_time_zone(PDT_TIME_ZONE)]
    end

    save_csv_to_file rows, doc_id, file_name
  end

  def send_address_reminder_to_idea_winners id
    challenge = Challenge.find id

    challenge.ideas.won.where(address_id: nil).each do |idea|
      NotificationCenter.notify_via_email :address_required, :challenge_idea, idea.id
    end
  end

  private
    def expire_cache challenge
      Cashier.expire "challenge-#{challenge.id}-projects", "challenge-#{challenge.id}-status"
      FastlyWorker.perform_async 'purge', challenge.record_key
    end

    def save_csv_to_file rows, doc_id, file_name
      csv_text = rows.map do |row|
        row.map{|v| "\"#{v}\"" }.join(',')
      end.join("\r\n")

      doc = Document.find doc_id

      file = StringIO.new csv_text
      file.class_eval { attr_accessor :original_filename }
      file.original_filename = file_name

      doc.file.store! file
      doc.save
    end
end