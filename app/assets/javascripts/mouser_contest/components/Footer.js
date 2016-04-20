import React, { PropTypes } from 'react';

const Footer = props => {
  return (
    <footer id="footer">
      <div className="stars" style={{ marginTop: 0, paddingTop: '20%' }}></div>
      <div className="content">
        <div className="brief">Already logged in here, waiting for designs.</div>
      </div>
    </footer>
  );
}

Footer.PropTypes = {
};

export default Footer;

