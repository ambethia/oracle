import React, { Component } from 'react';
import style from './app.scss';

export default class App extends Component {

  render() {
    return (
      <div className={style.app}>
        <div className={style.greeting}>
          <figure>
            <img src={require('../assets/logo.png')} />
          </figure>
          <h1>
            We are
            <em>Oracle</em>.
            Ask us a question.
          </h1>
        </div>
        <div className={style.overlay}></div>
      </div>
    );
  }
}
