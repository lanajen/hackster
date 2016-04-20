import request from 'superagent';
import { getApiPath } from '../utils/Utils';

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
  return new Promise((resolve, reject) => {
    request
      .get(`${getApiPath()}/projects?user_id=${userId}`)
      .end((err, res) => {
        const projects = res.body.projects.map(project => { return { value: project, label: project.name }; });
        err ? reject(err) : resolve(projects);
      });
  });
}

export function postProject(payload) {
  return new Promise((resolve, reject) => {
    request
      .post(`${getApiPath()}/submissions`)
      .send(payload)
      .withCredentials()
      .end((err, res) => {
        err ? reject(err) : resolve(res);
      });
  });
}

export function updateProjectStatus(update, projectId) {
  return new Promise((resolve, reject) => {
    request
      .patch(`${getApiPath()}/submissions/${projectId}`)
      .send(update)
      .withCredentials()
      .end((err, res) => {
        err ? reject(err) : resolve(res);
      })
  })
}