import React, { PropTypes } from 'react';
import { Link } from 'react-router'

const Toolbar = props => {
  return (
    <div>
      <Link to='/'>Home </Link>
      <Link to='particle'>Particle </Link>
      <Link to='arduino'>Arduino </Link>
      <Link to='admin'>Admin </Link>
    </div>
  );
};

Toolbar.PropTypes = {

};

export default Toolbar;