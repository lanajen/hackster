import { combineReducers } from 'redux';
import { routerReducer } from 'react-router-redux'

import admin from './admin';
import auth from './auth';
import contest from './contest';
<<<<<<< HEAD
import vendors from './vendors';
import user from './user';
||||||| merged common ancestors
import platforms from './platforms';
=======
import platforms from './platforms';
import user from './user';
<<<<<<< HEAD
>>>>>>> refactoring project import flow into redux
>>>>>>> refactoring project import flow into redux
>>>>>>> refactoring project import flow into redux
||||||| merged common ancestors
>>>>>>> refactoring project import flow into redux
>>>>>>> refactoring project import flow into redux
=======
>>>>>>> squashing

const rootReducer = combineReducers({
  admin,
  auth,
  contest,
<<<<<<< HEAD
  vendors,
  user,
||||||| merged common ancestors
  platforms,
=======
  platforms,
  user,
<<<<<<< HEAD
>>>>>>> refactoring project import flow into redux
>>>>>>> refactoring project import flow into redux
>>>>>>> refactoring project import flow into redux
||||||| merged common ancestors
>>>>>>> refactoring project import flow into redux
>>>>>>> refactoring project import flow into redux
=======
>>>>>>> squashing
  routing: routerReducer
});

export default rootReducer;
