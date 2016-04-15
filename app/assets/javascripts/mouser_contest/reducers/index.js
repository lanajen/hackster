import { combineReducers } from 'redux';
import { routerReducer } from 'react-router-redux'

import admin from './admin';
import auth from './auth';
import contest from './contest';
import platforms from './platforms';
import user from './user';

const rootReducer = combineReducers({
  admin,
  auth,
  contest,
  platforms,
  user,
  routing: routerReducer
});

export default rootReducer;
