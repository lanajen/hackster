import { createStore, applyMiddleware } from 'redux';
import thunk from 'redux-thunk';
import rootReducer from './reducers';
// import { routerMiddleware } from 'react-router-redux'

const createStoreWithMiddleware = applyMiddleware(
  thunk
)(createStore);

export default function configureStore() {
  return createStoreWithMiddleware(rootReducer);
}