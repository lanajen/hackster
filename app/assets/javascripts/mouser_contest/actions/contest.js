import { Contest } from '../constants';

export function setPhase(phase) {
  return {
    type: Contest.SET_PHASE,
    phase
  }
}