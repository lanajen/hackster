require 'rails_helper'

RSpec.describe Member do
  let(:group) { Group.create! }
  let(:user) { User.create!(email: 'hi@example.com', password: 'blahblah') }
  subject(:member) { Member.create!(user: user, group: group) }

  it 'exists' do
    expect(member).to be_valid
  end
end
