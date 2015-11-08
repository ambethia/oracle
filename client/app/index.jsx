import React, { Component } from 'react';
import style from './app.scss';

export default class App extends Component {

  render() {
    return (
      <div className={style.app}>
        <div className={style.greeting}>
          <h1>
            We are
            <article className={style.oracle}>
              <em className={style.oracle_glow}/>
              <em className={style.oracle_white}/>
            </article>
            Ask us a question.
          </h1>
        </div>
        <div className={style.overlay}></div>
      </div>
    );
  }
}
