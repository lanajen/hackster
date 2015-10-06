import React from 'react';
import PartFollowStatus from './PartFollowStatus'

const PartItem = React.createClass({

  handleStatusClick: function(){
    this.props.handleItemClick(this.props.id);
  },

  render: function() {
    let classes = ['part-thumb'];
    if (this.props.isFollowing) {
      classes.push('is-selected');
    }
    if (this.props.isLoading) {
      classes.push('is-loading');
    }
    let name = this.props.name;
    if (this.props.platform) {
      if (this.props.name.indexOf(this.props.platform.name) == -1)
        name = this.props.platform.name + ' ' + name;
    }

    return (
      <div className="col-md-4">
        <div className={classes.join(' ')}>
          <PartFollowStatus id={this.props.id} isFollowing={this.props.isFollowing} isLoading={this.props.isLoading} handleStatusClick={this.handleStatusClick} />
          <div className="img-container">
            <img src={this.props.image_url} />
          </div>
          <h3>
            <a>{name}</a>
          </h3>
        </div>
      </div>
    );
  },
});

export default PartItem;