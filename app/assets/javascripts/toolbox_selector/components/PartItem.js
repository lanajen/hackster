import React from 'react';

const PartItem = React.createClass({
  render: function() {

    return (
      <div className="part-item col-md-4">
        <img src={this.props.image_url} />
        <h4>
          <a href={this.props.url}>{this.props.name}</a>
        </h4>
      </div>
    );
  },
});

export default PartItem;