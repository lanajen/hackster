import React, { PropTypes } from 'react';
import { Link } from 'react-router'

const Navbar = props => {
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
 user: PropTypes.object.isRequired
};

export default Navbar;