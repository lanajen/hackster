
import { User } from '../constants';

const initialState = {
  id: null,
  projects: [],
  isAdmin: false,
  submissions: [],
  votes: []
}

export default function user(state = initialState, action) {
  switch(action.type) {

    case User.SET_USER_DATA:
      return {
        ...state,
        id: action.id,
        isAdmin: action.roles.indexOf('admin') !== -1
      };

    case User.SET_USER_PROJECTS:
      return { ...state, projects: action.projects };

    case User.SET_USER_SUBMISSIONS:
      return { ...state, submissions: action.submissions };

    default:
      return state;
  }
}