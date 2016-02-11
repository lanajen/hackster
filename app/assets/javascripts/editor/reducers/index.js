import { combineReducers } from 'redux';
import toolbar from './toolbar';
import editor from './editor';
import history from './history';
import logger from './logger';

const rootReducer = combineReducers({
  toolbar,
  editor,
  history,
  logger
});

export default rootReducer;
