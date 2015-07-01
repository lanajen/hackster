import { Store } from 'flummox';
import _ from 'lodash';

export default class FollowButtonStore extends Store {
  
  constructor(flux) {
    super();

    const followButtonActions = flux.getActions('followButton');

    this.state = {

    };
  }
}