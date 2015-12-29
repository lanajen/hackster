import React, { Component } from 'react';
import { Provider } from 'react-redux';
import Comments from './Comments';
import configureStore from '../store/configureStore';

const store = configureStore();

export default class Root extends Component {
  constructor(props) {
    super(props);
  }

  render() {
    console.log('HEYO!');
    return (
      <Provider store={store}>
        <Comments { ...this.props } />
      </Provider>
    );
  }
}