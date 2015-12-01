require 'rails_helper'

RSpec.describe Chores::GroupImpressionMoveWorker do
  let!(:group) { FactoryGirl.create(:group) }
  let(:impressionable_type) { 'Taco' }
  let(:controller_name) { 'tacos' }

  subject(:worker) { Chores::GroupImpressionMoveWorker.new }

  describe '.perform_async' do
    it 'enqueues a worker' do
      Chores::GroupImpressionMoveWorker.perform_async 'load_all'
      expect(Chores::GroupImpressionMoveWorker).to have_enqueued_job("load_all")
    end
  end

  describe '#perform' do
    class Impression20151119 < ActiveRecord::Base
      self.table_name = :impressions
    end

    before do
      Impression20151119.create!(
        impressionable_type: impressionable_type,
        impressionable_id: group.id,
        controller_name: controller_name,
        action_name: 'show',
        session_hash: SecureRandom.hex(10),
      )
    end

    context 'when an impression exists for a Group' do
      let(:impressionable_type) { 'Group' }

      context 'when the impression was created by the groups controller' do
        let(:controller_name) { 'groups' }

        it 'will get migrated' do
          expect { worker.perform('create_single_impression', Impression20151119.last.id) }.to change(GroupImpression, :count).by(1)
        end

        it 'will increment group counter' do
          worker.perform('create_single_impression', Impression20151119.last.id)
          expect(Group.first.impressions_count).to eq(1)
        end

        it 'will be queued' do
          worker.perform('load_all')
          expect(Chores::GroupImpressionMoveWorker).to have_enqueued_job('create_single_impression', Impression20151119.last.id)
        end

        it 'carries over the action name' do
          worker.perform('create_single_impression', Impression20151119.last.id)
          expect(GroupImpression.all.last.action_name).to eq('show')
        end

        context 'when the session hash already exists' do
          it 'will not increment group counter' do
            worker.perform('create_single_impression', Impression20151119.last.id)
            worker.perform('create_single_impression', Impression20151119.last.id)
            expect(Group.first.impressions_count).to eq(1)
          end
        end
      end

      context 'when the impression was not created by the groups controller' do
        it 'does not get migrated' do
          worker.perform('load_all')
          expect(Chores::GroupImpressionMoveWorker).not_to have_enqueued_job
        end
      end
    end

    context 'when an impression exists for something else' do
      it 'does not get migrated' do
        worker.perform('load_all')
        expect(Chores::GroupImpressionMoveWorker).not_to have_enqueued_job
      end
    end
  end
end
