import React, { Component } from 'react';
import ReactDOM from 'react-dom';
import _ from 'lodash'
import styles from './planchette.scss';

class Planchette extends Component {

  constructor(props) {
    super(props)
    this.debounceMouseMove = _.throttle(this.handleMouseMove.bind(this), 300);
  }

  handleMouseEnter(event) {
    console.log(event)
    document.addEventListener('mousemove', this.debounceMouseMove);
  }

  handleMouseLeave(event) {
    document.removeEventListener('mousemove', this.debounceMouseMove);
  }

  handleMouseMove(event) {
    const t = event.target;
    const x = (event.offsetX - (t.offsetWidth / 2));
    const y = (event.offsetY - (t.offsetHeight / 2));
    this.props.client.send(`move:${x}:${y}`);
  }

  render() {
    return (
      <div className={styles.planchette}
        style={this.props.position}
        onMouseDown={this.handleMouseEnter.bind(this)}
        onMouseUp={this.handleMouseLeave.bind(this)}
        onMouseLeave={this.handleMouseLeave.bind(this)}
         />
    );
  }
}

export default Planchette;
