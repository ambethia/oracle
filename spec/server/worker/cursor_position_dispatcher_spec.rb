require 'spec_helper'
require 'worker/cursor_position_dispatcher'

describe CursorPositionDispatcher do
  let(:redis) { double("Redis") }
  let(:websocket) { double("Websocket") }

  it 'does not dispatch a message if there are no keys in the system' do
    dispatcher = CursorPositionDispatcher.new(redis, websocket)
    expect(websocket).to_not receive(:send)
  end
end
