import { Contest } from '../constants';

export function setPhase(phase) {
  return {
    type: Platforms.SET_PHASE,
    phase
  }
}