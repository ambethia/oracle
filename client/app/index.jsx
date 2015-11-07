import React, { Component } from 'react';
import Faye from 'faye';

const client = new Faye.Client(__FAYE_CLIENT_URL__);

export default class App extends Component {
  handleClick() {
    client.publish('/move')
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
