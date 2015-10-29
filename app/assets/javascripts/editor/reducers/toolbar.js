import { Toolbar } from '../constants/ActionTypes';

const initialState = {
  showPopOver: false,
  popOverProps: {},
  activeButtons: [],
  CEWidth: null
};

export default function(state = initialState, action) {

  switch (action.type) {
    case Toolbar.showPopOver:
      return {
        ...state,
        showPopOver: action.bool,
        popOverProps: action.props
      };

    case Toolbar.toggleActiveButtons:
      return {
        ...state,
        activeButtons: action.list
      };

    case Toolbar.setCEWidth:
      return {
        ...state,
        CEWidth: action.width
      };

    default:
      return state;
  }
}