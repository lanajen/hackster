import React from 'react';
import { FlatButton } from 'material-ui';
import { addToFollowing, removeFromFollowing, getFollowing } from '../../utils/ReactAPIUtils';
import _ from 'lodash';

const FollowButton = React.createClass({

  getInitialState() {
    return {
      isHovered: false,
      csrfToken: null,
      isFollowing: null,
      spinner: false
    };
  },

  componentWillMount() {
    if(this.state.csrfToken === null) {
      let metaList, csrfToken;
      // If we have access to document, grab the csrf-token from the meta tag.
      if(document) {
        metaList = document.getElementsByTagName('meta');
        csrfToken = _.findWhere(metaList, {name: 'csrf-token'}).content;

        this.setState({csrfToken: csrfToken});
      }
    }
    // Gets an object of the Current Users followers from Local Storage and checks if this buttons followable id is among them.
    // if(global.localStorage) {
    //   this.setFollowing();
    // }
    if(!global.localStorage.getItem('following')) {
      let promise = _.once(getFollowing)();
      promise.then(function(res) {
        console.log(res);
        global.localStorage.setItem('following', JSON.stringify({yo: 'yoyoyo'}));
      }).catch(function(err) {
        console.log(err);
      });
    } else {
      console.log('LS EXISTS!');
    }
  },

  shouldComponentUpdate(nextProps, nextState) {
    return nextState !== this.state;
  },

  setFollowing() {
    if(this.props.followable) {
      let id = this.props.followable.id;
      let type = this.props.followable.type.toLowerCase();
      let following = JSON.parse(global.localStorage.getItem('following'));
      let isFollowing = false;
      
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
    let promise = this.handleFollowingCall();
    let isFollowing = this.state.isFollowing;

    // Sets label to spinner.
    this.setState({
      spinner: true
    });

    promise.then(function(response) {
      // Updates Local Storage and sets isFollowing.
      isFollowing === false ? this.addToLocalStorage(this.props.followable.id) : this.removeFromLocalStorage(this.props.followable.id);
      this.setFollowing();
    }.bind(this)).catch(function(err) {
      // Handle Error Message.
      console.log(err);
    });
  },

  handleFollowingCall() {
    let promise,
        followable = this.props.followable;

    if(!this.state.isFollowing) {
      promise = addToFollowing(followable.id, followable.type, this.state.csrfToken);
    } else {
      promise = removeFromFollowing(followable.id, followable.type, this.state.csrfToken);
    }

    return promise;
  },

  addToLocalStorage(id) {
    let storage = JSON.parse(global.localStorage.getItem('following'));
    let type = this.props.followable.type.toLowerCase();
    console.log('TEST', storage, type);
    storage[type].push(id);
    global.localStorage.setItem('following', JSON.stringify(storage));
  },

  removeFromLocalStorage(id) {
    let storage = JSON.parse(global.localStorage.getItem('following'));
    let type = this.props.followable.type.toLowerCase();
    let newStorage = _.filter(storage[type], function(item) {
      return item !== id;
    });

    global.localStorage.setItem('following', JSON.stringify(storage));
  },

  getStyles() {
    let styles = {
      button: {
        display: 'inline-block',
        color: 'white',
        textTransform: 'none',
        fontFamily: '"proxima-nova", "HelveticaNeue", Helvetica, Arial, "Lucida Grande", sans-serif',
        fontWeight: 'bold',
        padding: '5px 10px',
        lineHeight: '1.5',
        borderRadius: 4,
        fontSize: 14
      },
      append: {
        fontSize: 16,
        borderTopLeftRadius: 0,
        borderBottomLeftRadius: 0
      },
      text: {
        fontSize: '1em'
      },
      'text_wide': {
        display: 'block',
        width: '100%',
        fontSize: '1em',
        padding: '12px 12px 10px',
        overflow: 'hidden',
        textOverflow: 'ellipsis',
        whiteSpace: 'nowrap',
        marginBottom: 5
      },
      project: {
        display: 'block',
        width: '100%',
        fontSize: '1em',
        padding: '12px 12px 10px',
        overflow: 'hidden',
        textOverflow: 'ellipsis',
        whiteSpace: 'nowrap',
        marginBottom: 5,
        lineHeight: '1.42'
      }
    };
    return styles;
  },

  render: function() {
    let styles = this.getStyles();
    let buttonStyles = _.extend({}, styles.button, styles[this.props.buttonType] || null);
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

    buttonStyles = this.state.isHovered ? _.extend({}, buttonStyles, {backgroundColor: '#286090'}) : _.extend({}, buttonStyles, {backgroundColor: '#208edb'});

    return (
      <div>
        <FlatButton style={buttonStyles} onMouseOver={this.onButtonHover.bind(this, true)} onMouseOut={this.onButtonHover.bind(this, false)} onClick={this.onButtonClick}>
          {label}
        </FlatButton>
      </div>
    );
  }

});

export default FollowButton;