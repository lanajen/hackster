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
    case User.SET_ADMIN:
      return { ...state, isAdmin: action.bool };

    case User.SET_USER:
      return { ...state, id: action.id };

    case User.SET_PROJECTS:
      return { ...state, projects: action.projects };

    case User.SET_SUBMISSION:
      return { ...state, submission: action.project };

    default:
      return state;
  }
}