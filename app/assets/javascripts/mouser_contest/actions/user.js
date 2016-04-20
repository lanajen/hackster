import { User } from '../constants';
import { determineHost } from '../../utils/Mouser'

const API_PATH = determineHost();

/* Getting projects from Rails API by user_id  */
export function getProjects(userId) {
  userId = userId || 1;
  return dispatch => {
    return fetch(API_PATH + userId )
      .then(response => {
        return response.json();
      })
      .then(data => {
        const projects = data.projects.map(project => { return { value: project, label: project.name }; });
        dispatch(setProjects(projects));
      })
      .catch(err => console.log('ERROR', err))
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
    const { id, authors, name, communities } = getState().user.submission.value;
    const payload = {
      userId: authors[0].id,
      projectId: id,
      description: name,
      vendor: communities[0].id
    }
    fetch(API_PATH, {
      method: 'post',
      mode: 'no-cors',
      body: JSON.stringify(payload),
      headers: new Headers({
        'Content-Type': 'application/json',
        'Accept': 'application/json'
      })
    })
    .catch((err) => console.err(err))

  }
}

export function setUserAsAdmin(bool) {
  return {
    type: User.SET_ADMIN,
    bool
  }
}