import { User } from '../constants';
import { determineHost } from '../utils/utils';
import { fetchProjects, postProject } from '../requests';

// const { User } = constants;

// Getting projects from Rails API by user_id
export function getProjects(userId) {
  userId = userId || 1207;
  return dispatch => {
    return fetchProjects(userId)
      .then((projects) => dispatch(setProjects(projects)))
      .catch((err) => console.error('error?', err))
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
    const { id, authors, name, communities, vendor_tags } = getState().user.submission.value;
    const payload = {
      userId: authors[0].id,
      projectId: id,
      description: name,
      vendor_tags: vendor_tags || null,
      vendor_id: communities && communities[0] ? communities[0].id : -1
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