require 'rails_helper'

RSpec.describe ProjectImpression do
  it { is_expected.to belong_to(:project).counter_cache(:impressions_count) }
  it { is_expected.to belong_to(:user) }
end
