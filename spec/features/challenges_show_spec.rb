require 'rails_helper'

RSpec.describe 'challenges show view' do
  let!(:user) { FactoryGirl.create(:user) }
  let!(:platform) { FactoryGirl.create(:platform) }
  let!(:challenge) { FactoryGirl.create(:challenge, :in_progress, :with_platform, platform: platform) }


  context 'when user not logged in and a challenge exists' do

    before(:each) do
      visit '/challenges'
    end

    it 'has an endpoint by challenge slug' do
      expect(page).to have_link(challenge.name)
    end

    context 'user navigates to challenge page' do
      let!(:new_user) { FactoryGirl.build(:user) }

      before(:each) do
        find_link(challenge.name).click
      end

      it 'has an register button that will signup and register a new user', :js => true do
        within '.group-nav' do
          find_link('Register as a participant').click
        end

        within '#new_user' do
          fill_in "user_full_name", with: new_user.user_name
          fill_in "user_email", with: new_user.email
          click_on('Continue')
        end

        expect(page).to have_content('You\'re registered!')
      end
    end
  end

  context 'when a user is logged in and navigates to challenge page' do

    before(:each) do
      login_user(user)
      visit '/challenges'
      find_link(challenge.name).click
    end

    it 'has an register button that will register a user', :js => true do
      within '.group-nav' do
        find_link('Register as a participant').click
      end
      expect(page).to have_content('You\'re registered!')
    end

    context 'when workflow_state is pre_registration', :js => true do
      before(:each) do
        update_challenge_workflow_state('pre_registration', challenge)
      end

      it 'has a register button' do
        expect(page).to have_link('Register as a participant')
      end

      it 'has a countdown' do
        expect(page).to have_content('Submissions close in 10 days')
      end
    end

    context 'when workflow_state is pre_contest_in_progress and user attempts to submits an idea', :js => true do
      before(:each) do
        update_challenge_workflow_state('pre_contest_in_progress', challenge)
        click_link('Register as a participant', :match => :first)
        click_link('Submit an idea for the pre-contest')
      end

      it 'has navigates to ideas/new' do
        uri = URI.parse(current_url)
        expect(uri.path).to eq("/challenges/#{challenge.slug}/ideas/new")
      end

      it 'has a form that submits a new idea' do
        image = FactoryGirl.create(:image)

        page.execute_script('var el = document.createElement("input"); el.setAttribute("name", "challenge_idea[image_id]"); el.setAttribute("id", "challenge_idea_image_id"); document.getElementById("new_challenge_idea").appendChild(el);')
        page.execute_script('window.tinyMCE.activeEditor.setContent("cheeerz!");')

        within '#new_challenge_idea' do
          fill_in 'challenge_idea_name', with: 'Beerz'
          fill_in 'challenge_idea_image_id', with: image.id
          click_on('Submit my idea')
        end

        within '#new_idea_challenge_share_prompt' do
          expect(page).to have_content('Your idea is submitted!')
        end
      end

      context 'idea form' do
        let!(:required_field) { FactoryGirl.build(:challenge_idea_field, :required, position: 0) }
        let!(:hide_field) { FactoryGirl.build(:challenge_idea_field, :hide, position: 1) }
        let!(:normal_field) { FactoryGirl.build(:challenge_idea_field, position: 2) }

        before(:each) do
          challenge.challenge_idea_fields << required_field
          challenge.challenge_idea_fields << hide_field
          challenge.challenge_idea_fields << normal_field
          challenge.save
        end

        it 'displays required_field' do
          visit current_path

          within '.challenge_idea_cfield0' do
            expect(page).to have_content("* #{required_field.label}")
          end
        end

        it 'displays hide_field' do
          visit current_path

          within '.challenge_idea_cfield1' do
            expect(page).to have_content("#{hide_field.label}")
          end
        end

        it 'displays normal_field' do
          visit current_path

          within '.challenge_idea_cfield2' do
            expect(page).to have_content("#{normal_field.label}")
          end
        end

        it 'returns an error if required field is not filled out' do
          image = FactoryGirl.create(:image)

          visit current_path

          page.execute_script('var el = document.createElement("input"); el.setAttribute("name", "challenge_idea[image_id]"); el.setAttribute("id", "challenge_idea_image_id"); $("#new_challenge_idea").append(el);')
          page.execute_script('window.tinyMCE.activeEditor.setContent("cheeerz!");')

          within '#new_challenge_idea' do
            fill_in 'challenge_idea_name', with: 'Beerz'
            fill_in 'challenge_idea_image_id', with: image.id
            click_on('Submit my idea')
          end

          expect(page).to have_css('div.challenge_idea_cfield0.has-error')
        end
      end
    end

    context 'when workflow_state is pre_contest_in_progress and challenge has an idea', :js => true do
      let!(:idea) { FactoryGirl.create(:challenge_idea, challenge: challenge, user: user) }
      let!(:required_field) { FactoryGirl.build(:challenge_idea_field, :required, position: 0) }
      let!(:hide_field) { FactoryGirl.build(:challenge_idea_field, :hide, position: 1) }
      let!(:normal_field) { FactoryGirl.build(:challenge_idea_field, position: 2) }

      before(:each) do
        update_challenge_workflow_state('pre_contest_in_progress', challenge)
        challenge.challenge_idea_fields << required_field
        challenge.challenge_idea_fields << hide_field
        challenge.challenge_idea_fields << normal_field
        challenge.save

        idea.set_extra_fields()
        idea[:properties][:cfield0] = 'Required fields shown'
        idea[:properties][:cfield1] = 'Hidden fields are hidden'
        idea[:properties][:cfield2] = 'Normal fields are shown'
        idea.save

        click_link('Register as a participant', :match => :first)
      end

      it 'does not display without approval' do
        within '.entries-list' do
          expect(page).to have_content('Status: Awaiting moderation')
        end
      end

      it 'displays in /ideas after approval' do
        idea.update_column(:workflow_state, 'approved')
        idea.save

        visit "/challenges/#{challenge.slug}/ideas"
        within '.challenge-idea' do
          expect(page).to have_content(idea.name)
        end
      end

      context 'when a user clicks on view the full idea' do

        before(:each) do
          idea.update_column(:workflow_state, 'approved')
          idea.save

          visit "/challenges/#{challenge.slug}/ideas"
          within first('.challenge-idea') do
            click_on('View the full idea')
          end
        end

        it 'displays required fields' do
          within '#challenge-idea-popup' do
            expect(page).to have_content(required_field.label)
          end
        end

        it 'displays normal fields' do
          within '#challenge-idea-popup' do
            expect(page).to have_content(normal_field.label)
          end
        end

        it 'does not display hidden fields' do
          within '#challenge-idea-popup' do
            expect(page).not_to have_content(hide_field.label)
          end
        end
      end
    end

    context 'when workflow_state is pre_contest_ended', :js => true do
      let!(:idea) { FactoryGirl.create(:challenge_idea, :approved, challenge: challenge, user: user) }

      before(:each) do
        update_challenge_workflow_state('pre_contest_ended', challenge)
        click_link('Register as a participant', :match => :first)
      end

      it 'does not display a button for idea submissions' do
        expect(page).to_not have_content('Submit an idea for the pre-contest')
      end

      it 'displays the challenge end date' do
        expect(page).to have_content('Project submissions open in 24 hours')
      end
    end

    context 'when workflow_state is in_progress and a registered user submits an entry', :js => true do
      let!(:project) { FactoryGirl.create(:project, user: user) }

      before(:each) do
        click_link('Register as a participant', :match => :first)
        click_link('Submit an entry')
        select(project.name, :from => 'project_id')
        click_on('Enter my project into the challenge')
      end

      it 'will show a success modal' do
        within '#new_entry_challenge_share_prompt' do
          expect(page).to have_content('Your entry is submitted!')
        end
      end

      it 'will have a withdraw button that removes projects from challenge' do
        page.execute_script("$('.entry-withdraw').click();")
        page.driver.browser.switch_to.alert.accept

        within '.alert' do
          expect(page).to have_content('Your entry has been withdrawn.')
        end
      end

      it 'shows submitted project on /projects endpoint' do
        visit "/challenges/#{challenge.slug}/projects"

        within '.project-thumb' do
          expect(page).to have_content(project.name)
        end
      end
    end

    context 'when workflow_state is judging', :js => true do
      let!(:project) { FactoryGirl.create(:project, user: user) }
      let!(:challenge_entry) { FactoryGirl.create(:challenge_entry, project: project, user: user, challenge: challenge) }

      before(:each) do
        update_challenge_workflow_state('judging', challenge)
        click_link('Register as a participant', :match => :first)
      end

      it 'does not display a button' do
        expect(page).to_not have_content('Register as a participant')
      end

      it 'informs the user that the contest is over' do
        expect(page).to have_content('This contest is over and the winners are being selected.')
      end
    end

    context 'when workflow_state is judged', :js => true do
      let!(:project) { FactoryGirl.create(:project, user: user) }
      let!(:challenge_entry) { FactoryGirl.create(:challenge_entry, project: project, user: user, challenge: challenge) }

      before(:each) do
        update_challenge_workflow_state('judged', challenge)
        click_link('Register as a participant', :match => :first)
      end

      it 'displays the entries' do
        expect(find('.project-1')).to have_content(project.name)
      end
    end
  end
end