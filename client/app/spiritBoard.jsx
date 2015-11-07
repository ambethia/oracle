import React, { Component } from 'react';
import Planchette from './planchette';
import styles from './spiritBoard.scss';

class SpiritBoard extends Component {

  constructor(props) {
    super(props)
    this.client = new WebSocket(__FAYE_CLIENT_URL__);
  }

  handleClick() {
    console.log('hello');
    this.client.send('move');
  }

  componentWillMount() {
    this.client.onopen = (event) => {
      console.log('open');
      this.client.send('Hello, world!');
    };

    this.client.onmessage = (event) => {
      console.log('message', event.data);
    };

    this.client.onclose = (event) => {
      console.log('close', event.code, event.reason);
      this.client = null;
    };
  }

  render() {
    return (
      <div className={styles.spiritBoard}>
        <Planchette client={this.client} />
        <button>Hi.</button>
      </div>
    );
  }
}

export default SpiritBoard;
