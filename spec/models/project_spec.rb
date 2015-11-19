require 'rails_helper'

RSpec.describe Project do
  subject(:project) { FactoryGirl.create(:project) }

  it 'exists' do
    expect(project).to be_valid
  end

  describe '#slug_hid' do
    it 'is callable' do
      expect(project.slug_hid).to eq("#{project.slug}-#{project.hid}")
    end
  end

  describe '#impressions' do
    it 'has a association impressions' do
      expect(project).to respond_to(:impressions)
    end
  end

  describe '#impressions.count' do
    it 'gets the number of impressions' do
      expect(project.impressions.count).to eq(0)
    end

    context 'when there are recorded impressions' do
      before do
        impression = project.impressions.build
        impression.save
      end

      it 'has a single impression' do
        expect(project.impressions.count).to eq(1)
      end
    end
  end
end
