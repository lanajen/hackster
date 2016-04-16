import constants from '../constants';
import { determineHost } from '../utils/utils';
import { fetchProjects, postProject } from '../requests';

const API_PATH = determineHost();
const { User } = constants;

// Getting projects from Rails API by user_id
export function getProjects(userId) {
  userId = userId || 1;
  return dispatch => {
    return fetchProjects(userId)
      .then((projects) => dispatch(setProjects(projects)));
  }
}

function setProjects(projects) {
  return {
    type: User.SET_PROJECTS,
    projects
  }
}

/* Selecting a project / readying it for submission */
export function selectProject(project) {
  return {
    type: User.SET_SUBMISSION,
    project
  }
}

/* Submitting projects via POST to Rails API */
export function submitProject() {
  return (dispatch, getState) => {
    console.log('should be submitting project', getState());
    const { id, authors, name, communities } = getState().user.submission.value;
    const payload = {
      userId: authors[0].id,
      projectId: id,
      description: name,
      vendor: communities[0].id
    }
    return postProject(payload);
  }
}

export function setUserAsAdmin(bool) {
  return {
    type: User.SET_ADMIN,
    bool
  }
}