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

function setSubmissions(submissions) {
  return {
    type: User.SET_USER_SUBMISSIONS,
    submissions
  }
}

// export function selectProject(project) {
//   return {
//     type: User.SET_SUBMISSION,
//     project
//   };
// }

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
    // TODO: We need to set user submissions, so that we can filter out projects that already have been submitted.
    return postSubmission(submission);
  };
}