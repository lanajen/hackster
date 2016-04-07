import { Auth } from '../constants';

export function authorizeUser(bool) {
  return {
    type: Auth.SET_AUTHORIZED,
    bool
  };
}