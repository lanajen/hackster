import React, { Component, PropTypes } from 'react';

const TextInput = props => {
  return (
    <div className={`form-group ${props.valid ? '' : 'has-error'}`}>
      <label className='control-label' htmlFor={props.name}>{props.label}</label>
      <input type={props.type} className="form-control" name={props.name} onChange={props.onChange} autoFocus={props.focus}/>
      {props.message ? <div className='help-block'>{props.message}</div> : null}
    </div>
  )
}

TextInput.propTypes = {
  focus: PropTypes.bool,
  label: PropTypes.string,
  message: PropTypes.string,
  name: PropTypes.string,
  type: PropTypes.string,
  valid: PropTypes.bool,
  onChange: PropTypes.func
};

TextInput.defaultProps = {
  focus: false,
  label: '',
  message: '',
  name: '',
  type: 'text',
  valid: true,
  onChange: () => {}
};

export default TextInput;
