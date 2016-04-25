import { combineReducers } from 'redux';
import { routerReducer } from 'react-router-redux'

import admin from './admin';
import contest from './contest';
import vendors from './vendors';
import user from './user';

const rootReducer = combineReducers({
  admin,
  contest,
  vendors,
  user,
  routing: routerReducer
});

export default rootReducer;
