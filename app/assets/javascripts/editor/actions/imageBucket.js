import { ImageBucket } from '../constants/ActionTypes';

export function showFolder() {
  return {
    type: ImageBucket.show
  }
}

export function hideFolder() {
  return {
    type: ImageBucket.hide
  }
}