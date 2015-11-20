require 'rails_helper'

RSpec.describe Project do
  subject(:project) { Project.create! }

  it 'exists' do
    expect(project).to be_valid
  end

  describe '#slug_hid' do
    it 'is callable' do
      expect(project.slug_hid).to eq("#{project.slug}-#{project.hid}")
    end
  end
end
