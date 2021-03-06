import React, { PropTypes } from 'react';
import Navbar from './Navbar';

const Hero = props => {
  return (
    <section id="hero">
      <Navbar signoutUrl={props.signoutUrl} user={props.user} />
      <h1>#MAKERMADNESS</h1>
      <p>Which board will take it all?</p>
      <div className="bracket-container">
        <div className="bracket"></div>
        <div className="trophy"></div>
      </div>
    </section>
  );
}

Hero.PropTypes = {
  signoutUrl: PropTypes.string.isRequired,
  user: PropTypes.object.isRequired
};

export default Hero;
