require 'spec_helper'
require 'backend/mouse_move_handler'

describe MouseMoveHandler do
  it 'does not handle the message if its not a move event' do
    expect(MouseMoveHandler.should_handle? 'letter-select:A').to be false
  end

  it 'does handle move messages' do
    expect(MouseMoveHandler.should_handle? 'move:B').to be true
  end

  it 'when receiving a message it should insert it in to the redis' do
    redis = instance_double("Redis")
    handler = MouseMoveHandler.new(redis, 'client_id_foobar', 'move:B')
    expect(redis).to receive(:set).with('move:client_id_foobar', 'B')
    handler.handle!
  end
end
