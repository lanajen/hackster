require 'rails_helper'

RSpec.describe Chores::ProjectImpressionMoveWorker do
  let!(:project) { FactoryGirl.create(:project) }
  let(:impressionable_type) { 'Taco' }
  let(:controller_name) { 'tacos' }

  subject(:worker) { Chores::ProjectImpressionMoveWorker.new }

  describe '.perform_async' do
    it 'enqueues a worker' do
      Chores::ProjectImpressionMoveWorker.perform_async
      expect(Chores::ProjectImpressionMoveWorker).to have_enqueued_job
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
        action_name: 'fund',
      )
    end

    context 'when an impression exists for a BaseArticle' do
      let(:impressionable_type) { 'BaseArticle' }

      context 'when the impression was created by the projects controller' do
        let(:controller_name) { 'projects' }

        it 'will get migrated' do
          expect { worker.perform }.to change(ProjectImpression, :count).by(1)
        end

        it 'carries over the action name' do
          worker.perform
          expect(ProjectImpression.all.last.action_name).to eq('fund')
        end
      end

      context 'when the impression was not created by the projects controller' do
        it 'does not get migrated' do
          expect { worker.perform }.not_to change(ProjectImpression, :count)
        end
      end
    end

    context 'when an impression exists for something else' do
      it 'does not get migrated' do
        expect { worker.perform }.not_to change(ProjectImpression, :count)
      end
    end
  end
end
