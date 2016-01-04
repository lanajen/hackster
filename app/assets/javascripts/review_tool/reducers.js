/*
  {
    decisions: [
      {
        user: {},
        fields: {},
        decision: decision,
        createdAt: timestamp
      }
    ],
    comments: [
      {
        id: id,
        body: body,
        user: { id: id, name: name, avatar: url, slug: slug },
        createdAt: timestamp
      }
    ],
    events: [
      {
        user: {},
        action: action,
        meta: {},
        createdAt: timestamp
      }
    ]
  }
*/

import { combineReducers } from 'redux';
import {
  REQUEST_THREAD, RECEIVE_THREAD, SUBMIT_DECISION, SUBMIT_COMMENT,
  SET_DECISION_SUBMITTED, SET_COMMENT_SUBMITTED
} from './actions';

function sortItems(thread) {
  let items = [];

  addToCollectionByDate(thread.decisions, items, 'decision');
  addToCollectionByDate(thread.comments, items, 'comment');
  addToCollectionByDate(thread.events, items, 'event');

  return _.sortBy(items, 'createdAt');
}

function addToCollectionByDate(inputCollection, outputCollection, type) {
  _.forEach(inputCollection, function(el) {
    el.type = type;
    outputCollection.push(el);
  });

  return outputCollection;
}

function currentThread(state = {
  items: []
}, action) {
  let newState = Object.assign([], state);
  switch (action.type) {
    case REQUEST_THREAD:
      return state;

    case RECEIVE_THREAD:
      let items = sortItems(action.thread);
      let thread = {
        id: action.thread.id,
        status: action.thread.workflow_state,
        locked: action.thread.locked,
        hasDecisions: !!action.thread.decisions.length,
        isLoaded: true,
        items: items
      };
      if (thread.status == 'closed')
        items.push({
          type: 'event',
          message: 'This review thread is closed.'
        });
      return Object.assign({}, thread);

    case SET_DECISION_SUBMITTED:
      let decision = Object.assign({}, action.decision);
      decision.type = 'decision';
      newState.items.push(decision);
      newState.hasDecisions = true;
      return newState;

    case SET_COMMENT_SUBMITTED:
      let comment = Object.assign({}, action.comment);
      comment.type = 'comment';
      newState.items.push(comment);
      return newState;

    default:
      return state;
  }
}

function formStates(state = {
  decision: {
    isDisabled: false
  },
  comment: {
    isDisabled: false,
    textAreaValue: ''
  }
}, action) {
  switch (action.type) {
    case SUBMIT_DECISION:
      return Object.assign({}, state, {
        decision: {
          isDisabled: true
        }});

    case SET_DECISION_SUBMITTED:
      return Object.assign({}, state, {
        decision: {
          isDisabled: false
        }});

    case SUBMIT_COMMENT:
      return Object.assign({}, state, {
        comment: {
          isDisabled: true,
          textAreaValue: action.comment.body
        }
      });

    case SET_COMMENT_SUBMITTED:
      return Object.assign({}, state, {
        comment: {
          isDisabled: false,
          textAreaValue: ''
        }
      });

    default:
      return state;
  }
}

const rootReducer = combineReducers({
  currentThread,
  formStates
});

export default rootReducer;