import { combineReducers } from 'redux';
import toolbar from './toolbar';
import editor from './editor';
import history from './history';

const rootReducer = combineReducers({
  toolbar,
  editor,
  history
});

export default rootReducer;
