import { Flummox } from 'flummox';
import FollowButtonActions from './actions/FollowButtonActions';
import FollowButtonStore from './stores/FollowButtonStore';

export default class Flux extends Flummox {

  constructor() {
    super();

    this.createActions('followButton', FollowButtonActions);
    this.createStore('followButton', FollowButtonStore, this);

    // DEBUGGER
    // this.on('dispatch', function(payload) {
    //   console.log('dispatching -->', payload);
    // });
  }
}
