require 'spec_helper'
require 'worker/cursor_position_dispatcher'

describe CursorPositionDispatcher do
  def mock_redis_response(response = {})
    expect(CursorPositionDispatcher).to receive(:current_cursor_positions).and_yield(
      CursorResponse.new(response)
    )
  end

  let(:redis) { double("Redis") }
  let(:websocket) { double("Websocket") }
  let(:dispatcher) { CursorPositionDispatcher.new(redis, websocket) }

  it 'does not dispatch a message if there are no keys in the system' do
    mock_redis_response
    expect(websocket).to_not receive(:send)
    dispatcher.dispatch!
  end

  it 'finds the most popular letter and stores it in redis' do
    mock_redis_response({
      'move:user1' => 'A',
      'move:user2' => 'A',
      'move:user3' => 'Q'
    })

    expect(redis).to receive(:set).with('last-tick-letter', 'A')

    dispatcher.dispatch!
  end
end
