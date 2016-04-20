import { User } from '../constants';
import { fetchProjects, postProject } from '../requests';


export function setUser(id) {
  return {
    type: User.SET_USER,
    id
  }
}
export function getProjects(userId) {
  userId = 1207 || userId;
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
export function submitProject(project, currentVendor) {
  return (dispatch, getState) => {
    const user_id = getState().user.id || -1;
    const { id, cover_image_url } = project.value;
    const payload = {
      project_id: id,
      user_id: user_id,
      vendor_user_name: currentVendor.name,
      workflow_state: 'undecided',
      cover_image_url,

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