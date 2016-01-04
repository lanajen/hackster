import { combineReducers } from 'redux';
import toolbar from './toolbar';
import editor from './editor';

const rootReducer = combineReducers({
  toolbar,
  editor
});

export default rootReducer;
