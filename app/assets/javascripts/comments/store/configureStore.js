import { compose, createStore, applyMiddleware } from 'redux';
import thunk from 'redux-thunk';
import rootReducer from '../reducers';

const createStoreWithMiddleware = applyMiddleware(
  thunk
)(createStore);

const finalCreateStore = compose(
  applyMiddleware(thunk)
)(createStore);

export default function configureStore() {
  return finalCreateStore(rootReducer);
}