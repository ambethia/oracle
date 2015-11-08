import React, { Component } from 'react';
import Planchette from './planchette';
import styles from './spiritBoard.scss';

class SpiritBoard extends Component {

  constructor(props) {
    super(props)
    this.client = new WebSocket(__FAYE_CLIENT_URL__);
    this.state = {
      planchette: {
        top: '10px', left: '10px'
      }
    }
  }

  handleMessage(type, ...options) {
    switch (type) {
      case 'position':
        this.setState({
          planchette: {
            left: parseInt(this.state.planchette.left) + parseInt(options[0]) + 'px',
             top: parseInt(this.state.planchette.top)  + parseInt(options[1]) + 'px'
          }
        });
        break;
      default:
        console.log(type, options);
    }
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
      this.handleMessage(...event.data.split(':'));
    };

    this.client.onclose = (event) => {
      console.log('close', event.code, event.reason);
      this.client = null;
    };
  }

  render() {
    return (
      <div className={styles.spiritBoard}>
        <Planchette client={this.client} position={this.state.planchette} />
      </div>
    );
  }
}

export default SpiritBoard;
