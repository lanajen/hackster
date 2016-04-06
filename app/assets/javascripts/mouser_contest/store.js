/*Routing*/
import routes from './routes.js'
import { Router, browserHistory} from 'react-router'
import { syncHistoryWithStore, routerReducer } from 'react-router-redux'
/*Redux*/
import { createStore, combineReducers, applyMiddleware } from 'redux'
import MainReducer from './reducers/main'

const store = createStore(
  combineReducers({
  MainReducer,
  routing: routerReducer})
)


const reduxRouterMiddleware = syncHistoryWithStore(browserHistory, store)

//this is for use with the redux dev tools
// reduxRouterMiddleware.listenForReplays(store)

export default store