import { Platforms } from '../constants';

export default function platforms(state = [], action) {
  switch(action.type) {
    case Platforms.SET_PLATFORMS:
      // action.platforms
      return action.platforms;

    default:
      return state;
  }
}