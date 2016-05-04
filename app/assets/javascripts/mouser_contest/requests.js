import request from 'superagent';
import { getApiPath } from '../utils/Utils';

export function fetchSubmissionsByPage(page) {
  page = page || 1;
  return new Promise((resolve, reject) => {
    request
      .get(`${getApiPath()}/submissions`)
      .query({ page: page })
      .end((err, res) => {
        err ? reject(err) : resolve(res.body);
      });
  });
}

export function postActivePhase(phase) {
  return new Promise((resolve, reject) => {
    request
      .patch(`${getApiPath()}/phases/${phase}`)
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
        err
          ? reject(err)
          : resolve({
              projects: res.body.projects.map(project => { return { value: project, label: project.name } }),
              submissions: res.body.submissions
            });
      });
  });
}

export function postSubmission(payload) {
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

export function updateSubmissionStatus(submission, projectId) {
  const subMap = {
    'approved': 'approve',
    'rejected': 'reject'
  };

  return new Promise((resolve, reject) => {
    request
      .patch(`${getApiPath()}/submissions/${submission.id}/workflow`)
      .send({ event: subMap[submission.status] })
      .withCredentials()
      .end((err, res) => {
        err ? reject(err) : resolve(res);
      })
  })
}