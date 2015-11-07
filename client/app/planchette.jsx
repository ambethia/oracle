import React, { Component } from 'react';
import ReactDOM from 'react-dom';
import _ from 'lodash'
import styles from './planchette.scss';

class Planchette extends Component {

  // this.props.client.send('move');
  constructor(props) {
    super(props)
    this.debounceMouseMove = _.throttle(this.handleMouseMove.bind(this), 300);
  }

  componentDidMount() {
    ReactDOM.findDOMNode(this).style.left = '10px';
    ReactDOM.findDOMNode(this).style.top = '10px';
  }

  handleMouseEnter(event) {
    console.log('enter');
    document.addEventListener('mousemove', this.debounceMouseMove);
  }

  handleMouseLeave(event) {
    console.log('leave');
    document.removeEventListener('mousemove', this.debounceMouseMove);
  }

  handleMouseMove(event) {
    const t = event.target;
    const oX = event.offsetX - (t.offsetWidth / 2);
    const oY = event.offsetY - (t.offsetHeight / 2);
    this.props.client.send(`move:${oX}:${oY}`);
  }

  handleRemoteUpdate() {
    t = ReactDOM.findDOMNode(this);
    let nX = parseFloat(t.style.left) + x + 'px';
    let nY = parseFloat(t.style.top) + y + 'px';
    t.style.left = nX;
    t.style.top = nY;
  }

  render() {
    return (
      <div className={styles.planchette}
        onMouseDown={this.handleMouseEnter.bind(this)}
        onMouseUp={this.handleMouseLeave.bind(this)}
        onMouseLeave={this.handleMouseLeave.bind(this)}
         />
    );
  }
}

export default Planchette;
