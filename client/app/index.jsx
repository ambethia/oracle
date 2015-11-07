import React, { Component } from 'react';

let client = new WebSocket(__FAYE_CLIENT_URL__);

console.log(client);

client.onopen = function(event) {
  console.log('open');
  client.send('Hello, world!');
};

client.onmessage = function(event) {
  console.log('message', event.data);
};

client.onclose = function(event) {
  console.log('close', event.code, event.reason);
  client = null;
};

export default class App extends Component {
  handleClick() {
    client.send('move')
  }

  render() {
    return (
      <div>
        <h1>Hello, Rails Rumble!?</h1>
        <button onClick={this.handleClick} >Hi.</button>
      </div>
    );
  }
}
