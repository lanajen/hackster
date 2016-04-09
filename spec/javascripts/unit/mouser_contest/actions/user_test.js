import configureStore from 'mouser_contest/configStore';
import expect from 'expect';

import Redux, { createStore, applyMiddleware } from 'redux';
import thunk from 'redux-thunk';
import rootReducer from 'mouser_contest/reducers';

describe('testing our user reducer / user actions', () => {

  it('should fetch a user\'s eligible projects on page load', () => {
    console.log('this should be the store');
  })

  xit('should queue a selection for submission', () => {

  })

  xit('should submit a project', () => {

  })

});

