import { combineReducers } from 'redux';
import toolbar from './toolbar';
import imageBucket from './imageBucket';
import editor from './editor';

const rootReducer = combineReducers({
  toolbar,
  imageBucket,
  editor
});

export default rootReducer;
