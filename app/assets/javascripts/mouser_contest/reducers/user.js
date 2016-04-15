import { User } from '../constants';

const initialState = {
  id: null,
  projects: null,
  submission: null
}

export default function user (state = initialState, action) {

  switch(action.type) {
    case User.SET_PROJECTS:
      return {...state, projects: action.projects };

    case User.SET_SUBMISSION:
      return {...state, submission: action.project};

    default:
      return state;
  }

}
