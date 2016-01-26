import React from 'react';

const UniversityThumbnail = React.createClass({
  render: function() {
    const { id, name, location, logoUrl, url } = this.props;

    return (
      <div className='university-thumbnail'>
        <img src={logoUrl} />
        <div className='user-name'>
          <a href={url}>{name}</a>
        </div>
        <div>
          <i className='fa fa-map-marker' />
          <span>{location}</span>
        </div>
      </div>
    );
  }
});

export default UniversityThumbnail;