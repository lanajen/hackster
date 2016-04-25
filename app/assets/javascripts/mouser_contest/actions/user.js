import { User } from '../constants';
import { fetchProjects, postSubmission } from '../requests';

export function setUserData(data) {
  return {
    type: User.SET_USER_DATA,
    id: data.id,
    roles: data.roles || []
  };
}

export function getProjects(userId) {
  return dispatch => {
    userId = 484 || userId; // 484 <= Alex

    return fetchProjects(userId)
      .then(res => {
        dispatch(setProjects(res.projects));
        dispatch(setSubmissions(res.submissions));
      })
      .catch(err => console.error('fetchProjects Error: ', err));
  };
}

function setProjects(projects) {
  return {
    type: User.SET_USER_PROJECTS,
    projects
  };
}

function setSubmission(submission) {
  return {
    type: User.SET_USER_SUBMISSION,
    submission
  };
}

function setSubmissions(submissions) {
  return {
    type: User.SET_USER_SUBMISSIONS,
    submissions
  };
}

export function submitProject(project, currentVendor) {
  return (dispatch, getState) => {
    const userId = getState().user.id;
    const { id, cover_image_url } = project.value;
    const submission = {
      project_id: id,
      user_id: userId,
      vendor_user_name: currentVendor.name,
      workflow_state: 'undecided',
      cover_image_url
    };

    return postSubmission(submission)
      .then(res => dispatch(setSubmission(submission)))
      .catch(err => console.error('postSubmission Error ', err));
  };
}