import React, { PropTypes } from 'react';

const Hero = props => {
  return (
    <section id="hero">
      <div className="title">#MAKERMADNESS</div>
      <div className="brief">Which board will take it all?</div>
      <div className="bracket-container">
        <div className="bracket"></div>
        <div className="trophy"></div>
      </div>
    </section>
  );
}

Hero.PropTypes = {
};

export default Hero;