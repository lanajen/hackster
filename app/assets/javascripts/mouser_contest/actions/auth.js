import { Auth } from '../constants';
import { push } from 'react-router-redux';

export function authorizeUser(bool) {
  return {
    type: Auth.SET_AUTHORIZED,
    bool
  };
}

export function redirectToLogin(router) {
  return dispatch => {
    router.push('/');
  }
}