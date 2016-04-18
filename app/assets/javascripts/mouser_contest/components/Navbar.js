import React, { PropTypes } from 'react';
import { Link } from 'react-router'

const Navbar = props => {
  const { isAdmin } = props.user;

  return (
    <nav id="navbar">
      <div className="details-button-container">
        { isAdmin ? <Link to="/admin">Admin</Link> : null }
        <Link to="/">Event Details</Link>
      </div>
    </nav>
  );
};

Navbar.PropTypes = {
 user: PropTypes.object.isRequired
};

export default Navbar;