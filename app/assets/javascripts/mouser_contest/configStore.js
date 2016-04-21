import { createStore, applyMiddleware } from 'redux';
import thunk from 'redux-thunk';
import rootReducer from './reducers';

const createStoreWithMiddleware = applyMiddleware(
  thunk
)(createStore);

export default function configureStore() {
  return createStoreWithMiddleware(rootReducer);
<<<<<<< HEAD
}
||||||| merged common ancestors
}

=======
}



>>>>>>> added an auth component for route authentication
