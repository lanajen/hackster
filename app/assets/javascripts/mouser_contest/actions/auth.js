import { Auth } from '../constants';

export function authorizeUser(bool) {
  return {
    type: Auth.AUTHORIZE,
    bool
  };
}