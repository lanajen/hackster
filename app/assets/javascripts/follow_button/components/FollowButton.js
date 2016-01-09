import React from 'react';
import ReactDOM from 'react-dom';
import { addToFollowing, removeFromFollowing, getFollowing } from '../../utils/ReactAPIUtils';
import FollowersStore from '../stores/FollowersStore';
import postal from 'postal';
import _ from 'lodash';

const channel = postal.channel('followers');

const FollowButton = React.createClass({

  getInitialState() {
    return {
      isHovered: false,
      isFollowing: null,
      spinner: false,
      currentUserId: null
    };
  },

  componentWillMount() {
    this.initialSub = channel.subscribe('initial.store', function(data) {
      this.setFollowing(data.store);
      this.setState({
        currentUserId: data.currentUserId
      });
    }.bind(this));

    this.updateSub = channel.subscribe('store.changed', function(store) {
      this.setFollowing(store);
    }.bind(this));
  },

  componentWillUnmount: function() {
    this.initialSub.unsubscribe();
    this.updateSub.unsubscribe();
  },

  setFollowing(store) {
    if(this.props.followable) {
      let id = this.props.followable.id;
      let type = this.props.followable.type.toLowerCase();
      let isFollowing = false;
      let following = store || FollowersStore.getStore();

      _.forEach(following[type], function(item) {
        if(item === id) {
          isFollowing = true;
        }
      });

      this.setState({
        isFollowing: isFollowing,
        spinner: false
      });
    }
  },

  onButtonHover(bool) {
    let isHovered = bool;
    this.setState({
      isHovered: isHovered
    });
  },

  onButtonClick(e) {
    e.preventDefault();
    e.stopPropagation();
    let id = this.props.followable.id;
    let type = this.props.followable.type.toLowerCase();

    let promise = this.handleFollowingCall();

    // Sets label to spinner.
    this.setState({
      spinner: true
    });

    promise.then(function(response) {
      // Remove this hack when we bring in a React Dialog Component.
      if(response.headers['x-alert'] !== undefined) {
        // openModal is a Global jQuery function of modal.js.
        if(window) {
          let modal = window.document.createElement("DIV");
          modal.innerHTML = response.headers['x-alert'];
          window.document.body.appendChild(modal);
          window.openModal(response.headers['x-alert-id']);
        }
      }

      this.updateStore(id, type);
      ReactDOM.findDOMNode(this.refs.button).blur();
    }.bind(this)).catch(function(err) {
      console.log('Request Error: ' + err);
    });
  },

  handleFollowingCall() {
    let promise,
        followable = this.props.followable;

    if(!this.state.isFollowing) {
      promise = addToFollowing(followable.id, followable.type, followable.source, this.props.csrfToken);
    } else {
      promise = removeFromFollowing(followable.id, followable.type, followable.source, this.props.csrfToken);
    }

    return promise;
  },

  updateStore(id, type) {
    let isFollowing = this.state.isFollowing;
    isFollowing === false ? FollowersStore.addToStore(id, type) : FollowersStore.removeFromStore(id, type);
  },

  getClasses() {
    let classes = {
      'append': 'follow-button btn btn-primary btn-sm btn-block btn-append btn-short',
      'append_sandwich': 'follow-button btn btn-primary btn-sm btn-block btn-append btn-short',
      'append_hacker': 'follow-button btn btn-primary btn-sm btn-block btn-append btn-short',
      'shorter': 'follow-button btn btn-primary btn-sm btn-shorter',
      'community_shorter': 'follow-button btn btn-primary btn-sm btn-shorter community_shorter',
      'text': 'follow-button btn btn-primary',
      'text_wide': 'follow-button btn btn-primary btn-block btn-ellipsis react-button-margin-bottom',
      'part': 'follow-button btn btn-primary btn-block btn-sm',
      'project': 'follow-button btn btn-link btn-sm'
    };
    return classes;
  },


  render: function() {
    let classes = this.getClasses();
    let classList = classes[this.props.buttonType] || classes['text'];
    let disable = this.props.followable.type === 'User' && this.state.currentUserId === this.props.followable.id;
    let label;

    if(this.state.spinner) {
      label = <span className="fa fa-spinner fa-spin"></span>
    } else if(this.props.buttonType && this.props.buttonType === 'part') {
      label = this.state.isFollowing ? (<span><i className="fa fa-check"></i><span>In toolbox!</span></span>) :
              (<span>I own it!</span>);
    } else if(this.props.buttonType === 'project') {
      label = this.state.isFollowing ? (<span><i className="fa fa-check"></i><span>Made!</span></span>) :
              (<span><i className="fa fa-code-fork"></i><span>I made one</span></span>);
    } else {
      label = this.state.isFollowing ? (<span><i className="fa fa-check"></i><span>Following</span></span>) :
              this.props.followable.name ? (<span>Follow {this.props.followable.name}</span>) : (<span>Follow</span>);
    }

    return (
      <div>
        <button ref="button" className={classList} onMouseOver={this.onButtonHover.bind(this, true)} onMouseOut={this.onButtonHover.bind(this, false)} onClick={this.onButtonClick} disabled={disable}>
          {label}
        </button>
      </div>

    );
  }

});

export default FollowButton;