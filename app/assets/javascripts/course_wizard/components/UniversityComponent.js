import React from 'react';
import UniversitySearch from './UniversitySearch';
import UniversityThumbnail from './UniversityThumbnail';

const UniversityComponent = React.createClass({
  render: function() {
    const { university } = this.props;

    let comp = university ? (<UniversityThumbnail />) : (<UniversitySearch />);

    return (
      <div className=''>
        {comp}
      </div>
    );
  }
});

export default UniversityComponent;