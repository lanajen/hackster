import { Admin } from '../constants';
import { fetchSubmissions } from '../requests';

function makeProjects(amount) {
  amount = amount || 5;
  const vendors = [ 'TI', 'Intel', 'NXP', 'ST Micro', 'Cypress', 'Diligent', 'UDOO', 'Seeed Studio' ];
  const authors = [ 'Duder', 'Satan', 'Bowie', 'IndiaGuy', 'OtherDuder' ];
  const projects = [ 'Blinky lights', 'Water gun', 'Moar lights', 'VR porn', 'Drugs' ];

  function random(arr) {
    return arr[Math.floor(Math.random() * arr.length)];
  }

  function randomDate(start, end) {
    return new Date(start.getTime() + Math.random() * (end.getTime() - start.getTime()));
  }

  return Array.from(new Array(amount), () => {
    return {
      vendor: random(vendors),
      project: random(projects),
      author: random(authors),
      date: randomDate(new Date(2012, 0, 1), new Date()),
      status: random([ 'undecided', 'approved', 'rejected' ])
    };
  });
}

export function getSubmissions() {
  return dispatch => {
    dispatch(setSubmissions(makeProjects(30)));
    // return fetchSubmissions()
    //   .then(subs => {
    //     dispatch(setSubmissions(subs));
    //   })
    //   .catch(err => console.error('getSubmissions Error: ', err));
  };
}

function setSubmissions(submissions) {
  return {
    type: Admin.SET_SUBMISSIONS,
    submissions
  };
}

export function setFilters(filters) {
  return {
    type: Admin.SET_FILTERS,
    filters
  };
}