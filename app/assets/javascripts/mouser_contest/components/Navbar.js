import React, { PropTypes } from 'react';
import { Link } from 'react-router';

const Navbar = props => {
  const signoutUrl = props.signoutUrl;
  const { isAdmin } = props.user;

  return (
    <nav id="navbar">
      <div className="details-button-container">
        { isAdmin ? <Link to="/admin">Admin</Link> : null }
        <Link to="/">Event Details</Link>
      </div>
      <form action={signoutUrl} className="details-button-container" method="POST">
        <input type="hidden" name="_method" value="DELETE" />
        <input type="hidden" value={Utils.getCSRFToken()} name="authenticity_token" />
        <input type="hidden" value={window.location.origin} name="redirect_to" />
        <button type="submit">Log Out</button>
      </form>
    </nav>
  );
}

Navbar.PropTypes = {
  signoutUrl: PropTypes.string.isRequired,
  user: PropTypes.object.isRequired
};

export default Navbar;
