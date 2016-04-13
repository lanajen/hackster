import React, { PropTypes } from 'react';
import { Link } from 'react-router'

const Navbar = props => {
  return (
    <nav id="navbar">
      <div className="title-container">
        <a href="/" className="title">#MAKERMADNESS</a>
      </div>
      <div className="details-button-container">
        <button>Event Details</button>
      </div>
    </nav>
  );
};

Navbar.PropTypes = {
 user: PropTypes.object.isRequired
};

export default Navbar;