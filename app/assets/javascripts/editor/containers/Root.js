import React, { Component } from 'react';
import { Provider } from 'react-redux';
import Editor from './Editor';
import configureStore from '../store/configureStore';

const store = configureStore();

export default class Root extends Component {
  constructor(props) {
    super(props);

    this.state = { hashLocation: window.location.hash };
  }

  componentWillMount() {
    window.addEventListener('hashchange', this.handleLocationHash.bind(this));
  }

  componentWillUnmount() {
    window.removeEventListener('hashchange', this.handleLocationHash.bind(this));
  }

  handleLocationHash() {
    this.setState({
      hashLocation: window.location.hash
    });
  }

  render() {
    /** Temp fix for Rails router pagination.  This is the main stoppage block since its responsible for passing state from our stores
      * to these components.  We will never render past this point after any async actions if this block is hit.
     */
    if(this.state.hashLocation !== '#story') {
      return null;
    }

    return (
      <Provider store={store}>
        {() => <Editor hashLocation={this.state.hashLocation} />}
      </Provider>
    );
  }
}