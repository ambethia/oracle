require 'spec_helper'
require 'backend/message_dispatcher'


describe MessageDispatcher do
  let(:client) { double('Client') }
  let(:redis)  { double('Redis') }
  let(:dispatcher) { MessageDispatcher.new(redis, 'client_id_foobar', [client], message) }

  before(:each) {
    allow(redis).to receive(:set).and_return(nil)
  }

  context 'non-mouse moves' do
    let(:message) { 'letter-selected:B' }

    it 'can dispatch messages to the clients' do
      expect(client).to receive(:send).with(message)
      dispatcher.dispatch!
    end
  end

  context 'mouse moves' do
    let(:message) { 'move:A' }

    it 'does not dispatch mouse moves to the client' do
      expect(client).to_not receive(:send)
      dispatcher.dispatch!
    end

    it 'notifies the mouse move handler of the event' do
      expect_any_instance_of(MouseMoveHandler).to receive(:handle!).and_return(nil)
      dispatcher.dispatch!
    end
  end
end
