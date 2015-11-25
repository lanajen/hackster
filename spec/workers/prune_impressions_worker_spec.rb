require 'rails_helper'

RSpec.describe Chores::PruneImpressionsWorker do
  subject(:worker) { Chores::PruneImpressionsWorker.new }

  it 'does exist' do
    expect(worker).to be
  end

  context 'when there is a project impression' do
    let(:project) { FactoryGirl.create(:project) }
    let!(:impresssion) { Impression.create(impressionable: project, controller_name: 'projects') }

    it 'deletes an impression' do
      expect {
        worker.perform
      }.to change(Impression, :count).by(-1)
    end
  end

  context 'when there is a user impression' do
    let(:user) { FactoryGirl.create(:user) }
    let!(:impresssion) { Impression.create(impressionable: user, controller_name: 'users') }

    it 'deletes an impression' do
      expect {
        worker.perform
      }.to change(Impression, :count).by(0)
    end
  end
end
