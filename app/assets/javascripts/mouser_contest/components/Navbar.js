import React, { PropTypes } from 'react';
import { Link } from 'react-router'

const Navbar = props => {
  const { isAdmin } = props.user;

  return (
    <nav id="navbar">
      <div className="title-container">
        <Link to="/" className="title">#MAKERMADNESS</Link>
      </div>
      <div className="details-button-container">
        { isAdmin ? <Link to="/admin" className="fa fa-cog"></Link> : null }
        <button>Event Details</button>
      </div>
    </nav>
  );
};

Navbar.PropTypes = {
 user: PropTypes.object.isRequired
};

export default Navbar;