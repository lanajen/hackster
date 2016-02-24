module Helpers
  def login_user(user)
    user = user || FactoryGirl.create(:user)
    visit '/'
    click_on 'Log in'
    within '#login-form' do
      fill_in "user_email", with: user.email
      fill_in "user_password", with: user.password
      click_on 'Log into my account'
    end
  end

  def update_challenge_workflow_state(state, challenge)
    case state
    when 'pre_registration'
      challenge.update_attribute(:pre_registration_start_date, 1.day.from_now)
      challenge.update_attribute(:pre_contest_start_date, 2.days.from_now)
      challenge.update_attribute(:pre_contest_end_date, 3.days.from_now)
      challenge.update_attribute(:start_date, 5.days.from_now)
      challenge.update_attribute(:workflow_state, 'pre_registration')
      challenge.save
    when 'pre_contest_in_progress'
      challenge.update_attribute(:pre_contest_start_date, Time.now)
      challenge.update_attribute(:pre_contest_end_date, 1.day.from_now)
      challenge.update_attribute(:start_date, 5.days.from_now)
      challenge.update_attribute(:workflow_state, 'pre_contest_in_progress')
      challenge.ready = true
      challenge.save
    when 'pre_contest_ended'
      challenge.update_attribute(:pre_registration_start_date, 3.days.ago)
      challenge.update_attribute(:pre_contest_start_date, 2.days.ago)
      challenge.update_attribute(:pre_contest_end_date, Time.now)
      challenge.update_attribute(:start_date, 1.day.from_now)
      challenge.update_attribute(:end_date, 2.days.from_now)
      challenge.update_attribute(:workflow_state, 'pre_contest_ended')
      challenge.save
    when 'judging'
      challenge.update_attribute(:pre_registration_start_date, 3.days.ago)
      challenge.update_attribute(:pre_contest_start_date, 2.days.ago)
      challenge.update_attribute(:pre_contest_end_date, 1.day.ago)
      challenge.update_attribute(:start_date, 1.day.ago)
      challenge.update_attribute(:end_date, Time.now)
      challenge.update_attribute(:workflow_state, 'judging')
      challenge.save
    when 'judged'
      challenge.update_attribute(:pre_registration_start_date, 3.days.ago)
      challenge.update_attribute(:pre_contest_start_date, 2.days.ago)
      challenge.update_attribute(:pre_contest_end_date, 1.day.ago)
      challenge.update_attribute(:start_date, 1.day.ago)
      challenge.update_attribute(:end_date, Time.now)
      challenge.update_attribute(:workflow_state, 'judged')
      challenge.save
    else
      return
    end
  end
end

RSpec.configure do |config|
  config.include Helpers, :type => :feature
end