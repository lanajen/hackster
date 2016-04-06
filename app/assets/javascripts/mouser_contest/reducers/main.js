import store from '../store.js'


const initialState = {};


const MainReducer = (state = initialState, action) => {

  switch(action.type) {
    case 'testing':
      console.log('just testing');

    default:
      return state;
  }
}



export default MainReducer