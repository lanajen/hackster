require 'rails_helper'

RSpec.describe Chores::ProjectImpressionMoveWorker do
  let!(:project) { FactoryGirl.create(:project) }
  let(:impressionable_type) { 'Taco' }
  let(:controller_name) { 'tacos' }

  subject(:worker) { Chores::ProjectImpressionMoveWorker.new }

  describe '.perform_async' do
    it 'enqueues a worker' do
      Chores::ProjectImpressionMoveWorker.perform_async 'load_all'
      expect(Chores::ProjectImpressionMoveWorker).to have_enqueued_job("load_all")
    end
  end

  describe '#perform' do
    class Impression20151119 < ActiveRecord::Base
      self.table_name = :impressions
    end

    before do
      Impression20151119.create!(
        impressionable_type: impressionable_type,
        impressionable_id: project.id,
        controller_name: controller_name,
        action_name: 'show',
        session_hash: SecureRandom.hex(10),
      )
    end

    context 'when an impression exists for a BaseArticle' do
      let(:impressionable_type) { 'BaseArticle' }

      context 'when the impression was created by the projects controller' do
        let(:controller_name) { 'projects' }

        it 'will get migrated' do
          expect { worker.perform('create_single_impression', Impression20151119.last.id) }.to change(ProjectImpression, :count).by(1)
        end

        it 'will increment project counter' do
          worker.perform('create_single_impression', Impression20151119.last.id)
          expect(Project.first.impressions_count).to eq(1)
        end

        it 'will be queued' do
          worker.perform('load_all')
          expect(Chores::ProjectImpressionMoveWorker).to have_enqueued_job('create_single_impression', Impression20151119.last.id)
        end

        it 'carries over the action name' do
          worker.perform('create_single_impression', Impression20151119.last.id)
          expect(ProjectImpression.all.last.action_name).to eq('show')
        end

        context 'when the session hash already exists' do
          it 'will not increment project counter' do
            worker.perform('create_single_impression', Impression20151119.last.id)
            worker.perform('create_single_impression', Impression20151119.last.id)
            expect(Project.first.impressions_count).to eq(1)
          end
        end
      end

      context 'when the impression was not created by the projects controller' do
        it 'does not get migrated' do
          worker.perform('load_all')
          expect(Chores::ProjectImpressionMoveWorker).not_to have_enqueued_job
        end
      end
    end

    context 'when an impression exists for something else' do
      it 'does not get migrated' do
        worker.perform('load_all')
        expect(Chores::ProjectImpressionMoveWorker).not_to have_enqueued_job
      end
    end
  end
end
