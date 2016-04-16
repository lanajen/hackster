import request from 'superagent';
import { getApiPath } from '../utils/Utils';

//use this until we get the working version of getApiPath
import { determineHost } from './utils/utils';

export function fetchSubmissions() {
  return new Promise((resolve, reject) => {
    request
      .get(`${getApiPath()}/submissions`)
      .end((err, res) => {
        err ? reject(err) : resolve(res);
      });
  });
}

export function postActivePhase(phase) {
  return new Promise((resolve, reject) => {
    request
      .put(`${getApiPath()}/phases/${phase}`)
      .withCredentials()
      .end((err, res) => {
        err ? reject(err) : resolve(res);
      });
  });
}

export function fetchProjects(userId) {
  return fetch(`${determineHost()}/api/import?user_id=${userId}`)
    .then(response => {
      return response.json();
    })
    .then(data => {
      return data.projects.map(project => { return { value: project, label: project.name }; });
    })
    .catch(err => console.error('error from useractions', err))
}

export function postProject(payload) {
  return fetch(`${determineHost()}/api/submit`, {
    method: 'post',
    mode: 'no-cors',
    body: JSON.stringify(payload),
    headers: new Headers({
      'Content-Type': 'application/json',
      'Accept': 'application/json'
    })
  })
  .catch((err) => console.error(err))
}