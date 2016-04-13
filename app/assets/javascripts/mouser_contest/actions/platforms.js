import { Platforms } from '../constants';

export function setPlatforms(platforms) {
  return {
    type: Platforms.SET_STATE,
    platforms
  }
}