import { combineReducers } from 'redux';
import { routerReducer } from 'react-router-redux'

<<<<<<< HEAD
import admin from './admin';
import auth from './auth';
<<<<<<< HEAD
import contest from './contest';
<<<<<<< HEAD
import vendors from './vendors';
import user from './user';
||||||| merged common ancestors
import platforms from './platforms';
=======
import platforms from './platforms';
||||||| merged common ancestors
=======
||||||| merged common ancestors
import auth from './auth';
=======
// import auth from './auth';
import user from './user';
>>>>>>> refactoring project import flow into redux
>>>>>>> refactoring project import flow into redux
>>>>>>> refactoring project import flow into redux

const rootReducer = combineReducers({
<<<<<<< HEAD
  admin,
  auth,
<<<<<<< HEAD
  contest,
<<<<<<< HEAD
  vendors,
  user,
||||||| merged common ancestors
  platforms,
=======
  platforms,
||||||| merged common ancestors
=======
||||||| merged common ancestors
  auth,
=======
  user,
>>>>>>> refactoring project import flow into redux
>>>>>>> refactoring project import flow into redux
>>>>>>> refactoring project import flow into redux
  routing: routerReducer
});

export default rootReducer;
