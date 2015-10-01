import React from 'react';

const PartFollowStatus = React.createClass({

  getInitialState: function(){
    return {
      isHovering: false
    };
  },

  handleOnMouseOver: function(e){
    this.setState({ isHovering: true });
  },

  handleOnMouseOut: function(e){
    this.setState({ isHovering: false });
  },

  handleStatusClick: function(e){
    e.preventDefault();
    if (this.state.isLoading) return;
    this.props.handleStatusClick();
  },

  render: function() {
    let status;
    if (this.props.isLoading) {
      status = (<i className="fa fa-check" style={{ color: '#ddd' }}></i>);
    } else if (this.props.isFollowing) {
      status = (<i className="fa fa-check" style={{ color: '#6ADE47' }}></i>);
    } else if (this.state.isHovering) {
      status = (<i className="fa fa-check" style={{ color: '#ddd', textShadow: '0 0 1px #333' }}></i>);
    }

    return (
      <a className="status" href="javascript:void(0)" onClick={this.handleStatusClick} onMouseEnter={this.handleOnMouseOver} onMouseLeave={this.handleOnMouseOut}>{status}</a>
    );
  },
});

export default PartFollowStatus;