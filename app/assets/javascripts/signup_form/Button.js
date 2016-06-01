import React, { PropTypes } from 'react';

const Button = props => {
  const className = 'btn ' + props.className;
  
  return (
    <button className={className} onClick={props.onClick} style={props.style}>
      {props.children}
    </button>
  );
};

Button.propTypes = {
  className: PropTypes.string,
  onClick: PropTypes.func,
  style: PropTypes.object
};

Button.defaultProps = {
  className: '',
  onClick: () => {},
  style: {}
};

export default Button;
