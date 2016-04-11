import { combineReducers } from 'redux';
import { routerReducer } from 'react-router-redux'

import admin from './admin';
import auth from './auth';

const rootReducer = combineReducers({
  admin,
  auth,
  routing: routerReducer
});

export default rootReducer;
