require 'rails_helper'

RSpec.describe Project do
  subject(:project) { FactoryGirl.create(:project, id: 66) }

  it { is_expected.to have_many(:impressions).class_name('ProjectImpression').dependent(:destroy) }
  it { is_expected.to be_impressionable }

  describe '#slug_hid' do
    it 'is callable' do
      expect(project.slug_hid).to eq("#{project.slug}-#{project.hid}")
    end
  end

  describe '#impressions.count' do
    it 'gets the number of impressions' do
      expect(project.impressions.count).to eq(0)
    end

    it 'is updated properly when an impression is added' do
      expect { project.impressions.create! }.to change(ProjectImpression, :count).by(1)
    end
  end
end
