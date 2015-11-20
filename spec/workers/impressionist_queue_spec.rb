require 'rails_helper'

RSpec.describe ImpressionistQueue do
  subject(:impressionist_queue) { ImpressionistQueue.new }

  describe '#count' do
    let(:user) { FactoryGirl.create(:user, id: 45) }

    it 'calls impressionist' do
      finder = double(:finder, find: user)
      obj_type = double(:user, constantize: finder)

      expect(impressionist_queue).to receive(:impressionist).with(user, 'message', anything)

      impressionist_queue.count('env', 'action_name', 'controller_name', 'params', 45, obj_type, 'message', {})
    end
  end
end
