class ChallengeCriticalWorker < BaseWorker
  sidekiq_options queue: :critical, retry: 0

  def generate_entries_csv challenge_id, doc_id, file_name
    challenge = Challenge.find challenge_id
    entries = challenge.entries.joins(:project, :user).includes(:prizes, user: :avatar, project: :team).order(:created_at)

    headers = ['ID', 'Project name', 'Project URL', 'Project created on', 'Authors', 'Entrant name', 'Entrant email', 'Tags', 'Completion', 'Views count', 'Respects count', 'Comments count', 'Replications count', 'Entry status']
    rows = [headers]

    entries.each do |entry|
      project = entry.project
      row = []
      row << entry.id
      row << project.name
      row << "https://www.hackster.io/#{project.uri}"
      row << project.created_at
      row << project.users.map(&:name).to_sentence
      row << entry.user.name
      row << entry.user.email
      row << project.product_tags_string
      row << "#{project.checklist_completion}%"
      row << project.impressions_count
      row << project.respects_count
      row << project.comments_count
      row << (project.respond_to?(:replications_count) ? project.replications_count : '')
      row << entry.workflow_state
      rows << row
    end

    save_csv_to_file rows, doc_id, file_name
  end

  def generate_ideas_csv challenge_id, doc_id, file_name
    challenge = Challenge.find challenge_id
    ideas = challenge.ideas.order(:created_at).joins(:user).includes(:address, :image, user: :avatar)

    headers = ['ID', 'Name', 'Description', 'Image URL', 'Permalink']
    headers += challenge.challenge_idea_fields.map(&:label)
    headers += ['Submitter name', 'Submission date', 'Submission status', 'Email']
    headers += ['Full name', 'Address line 1', 'Address line 2', 'City', 'State', 'Zip code', 'Country', 'Phone number']
    rows = [headers]
    ideas.each do |idea|
      user = idea.user
      output = [idea.id, idea.name, ActionController::Base.helpers.strip_tags(idea.description).gsub(/"/, '""'), idea.image.try(:imgix_url, :thumb), "https://www.hackster.io/challenges/#{challenge.slug}/ideas/#{idea.id}"]
      output += challenge.challenge_idea_fields.each_with_index.map{|f, i| idea.send("cfield#{i}").try(:gsub, /"/, '""') }
      output += [user.name, idea.created_at.in_time_zone(PDT_TIME_ZONE), idea.workflow_state, user.email]
      address = idea.address
      output += [address.full_name, address.address_line1, address.address_line2, address.city, address.state, address.zip, address.country, address.phone]
      rows << output
    end

    save_csv_to_file rows, doc_id, file_name
  end

  def generate_participants_csv challenge_id, doc_id, file_name
    challenge = Challenge.find challenge_id
    registrations = challenge.registrations.joins(:user).includes(:user).order("users.full_name ASC")

    headers = ['Name', 'Email', 'Registration date']
    headers += challenge.challenge_entry_fields.map(&:label)
    rows = [headers]
    registrations.each do |registration|
      user = registration.user
      output = [user.name, user.email, registration.created_at.in_time_zone(PDT_TIME_ZONE)]
      output += challenge.challenge_entry_fields.each_with_index.map{|f, i| idea.send("cfield#{i}").try(:gsub, /"/, '""') }
      rows << output
    end

    save_csv_to_file rows, doc_id, file_name
  end

  private
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