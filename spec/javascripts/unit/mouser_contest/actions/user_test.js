import expect from 'expect';
import fetchMock from 'fetch-mock';

import * as actions from 'mouser_contest/actions/user';
import * as constants from 'mouser_contest/constants';

import thunk from 'redux-thunk';
import configureStore from 'redux-mock-store';

const middlewares = [thunk];
const mockStore = configureStore(middlewares);

const initialState = {
  id: null,
  projects: null,
  submission: null
}

const resetState = () => {
  return initialState.map( (prop) => { return null; } );
}

describe('testing our user actions', () => {

  afterEach(fetchMock.restore);

  it('should dispatch SET_PROJECTS when getProjects has finished', () => {
    const store = mockStore(initialState);
    const sampleResponse = [
      {
        value: { name: 'dog doorbell'},
        name: 'dog doorbell'
      },
      {
        value: { name: 'wireless tupee'},
        name: 'wireless tupee'
      }
    ];
    const sampleProjects = sampleResponse.map((p,k) => ({value: p, label: p.name}))
    const expectedActions = [
      { type: 'SET_PROJECTS', projects: sampleProjects }
    ];

    fetchMock
      .mock('http://mousercontest.localhost.local:5000/projects?user_id=1', 'GET', { projects: sampleResponse })

    return store.dispatch(actions.getProjects())
      .then(() => {
        expect(store.getActions()).toEqual(expectedActions);
      })
  })

  it('should dispatch SET_SUBMISSION when selectProject is called', () => {
    const store = mockStore(initialState);

    const  sampleProject = {
      value: { name: 'wireless tupee'},
      name: 'wireless tupee'
    }
    const expectedActions = [{
      type: 'SET_SUBMISSION',
        project: {
          value: { name: 'wireless tupee'},
          name: 'wireless tupee'
        }
      }];

    store.dispatch(actions.selectProject(sampleProject));
    expect(store.getActions()).toEqual(expectedActions);

  })
});
