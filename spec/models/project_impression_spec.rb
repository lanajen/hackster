require 'rails_helper'

RSpec.describe ProjectImpression do
  it { is_expected.to belong_to(:project) }
  it { is_expected.to belong_to(:user) }
end
