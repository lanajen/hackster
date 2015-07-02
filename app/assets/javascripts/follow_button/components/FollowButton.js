import React from 'react';
import { FlatButton } from 'material-ui';
import _ from 'lodash';

const FollowButton = React.createClass({

  getInitialState() {
    return {
      isHovered: false
    };
  },

  shouldComponentUpdate(nextProps, nextState) {
    return nextState !== this.state;
  },

  onButtonHover(bool) {
    let isHovered = bool;
    this.setState({
      isHovered: isHovered
    });
  },

  getStyles() {
    let styles = {
      button: {
        display: 'inline-block',
        color: 'white',
        textTransform: 'none',
        fontFamily: '"proxima-nova", "HelveticaNeue", Helvetica, Arial, "Lucida Grande", sans-serif',
        fontSize: '0.85em',
        fontWeight: 'bold',
        padding: '5px 10px',
        lineHeight: '1.5',
        borderRadius: 3
      }
    };
    return styles;
  },

  render: function() {
    console.log('FB props', this.props);
    let styles = this.getStyles();
    let label = this.props.isFollowing ? (<span><i className="fa fa-check"></i><span>Following</span></span>) : (<span>Follow</span>);

    let buttonStyles = this.state.isHovered ? _.extend(styles.button, {backgroundColor: '#286090'}) : _.extend(styles.button, {backgroundColor: '#208edb'});

    return (
      <div>
        <FlatButton style={styles.button} onMouseOver={this.onButtonHover.bind(this, true)} onMouseOut={this.onButtonHover.bind(this, false)}>
          {label}
        </FlatButton>
      </div>
    );
  }

});

export default FollowButton;