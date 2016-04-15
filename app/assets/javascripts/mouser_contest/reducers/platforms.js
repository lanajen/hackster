import { Platforms } from '../constants';

export default function platforms(state = [], action) {
  switch(action.type) {
    case Platforms.SET_PLATFORMS:
      // action.platforms
      console.log('this is the action from platforms reducer ', action)
      return action.platforms;

    default:
      return state;
  }
}