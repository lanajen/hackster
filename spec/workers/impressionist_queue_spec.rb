require 'rails_helper'

RSpec.describe ImpressionistQueue do
  subject(:impressionist_queue) { ImpressionistQueue.new }
  let(:project) { FactoryGirl.create(:project) }

  describe '#count' do
    it 'calls impressionist' do
      expect(impressionist_queue.count('env', 'action_name', 'controller_name', 'params', project[:id], project.class))
      expect(impressionist_queue.impressionist).to be_called_with(project, )
    end
  end
end
