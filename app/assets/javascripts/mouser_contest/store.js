/*Routing*/
import routes from './routes'
import { Router, browserHistory} from 'react-router'
import { syncHistoryWithStore, routerReducer } from 'react-router-redux'
/*Redux*/
import { createStore, combineReducers, applyMiddleware } from 'redux'
import MainReducer from './reducers/main'

const store = createStore(
  combineReducers({
    MainReducer,
    routing: routerReducer
  })
);


const history = syncHistoryWithStore(browserHistory, store);

export {
  history,
  store
}