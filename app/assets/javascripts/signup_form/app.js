import React, { Component, PropTypes } from 'react';
import ReactCSSTransitionGroup from 'react-addons-css-transition-group';
import validator from 'validator';

import api from '../utils/ReactAPIUtils.js';

import Button from './Button';
import Dialog from './Dialog';
import TextInput from './TextInput';

class SignupForm extends Component {
  constructor(props) {
    super(props);

    this.handleSubmit = this.handleSubmit.bind(this);
    this.toggleDialog = this.toggleDialog.bind(this);
    this.updateEmail = this.updateEmail.bind(this);
    this.updateFullName = this.updateFullName.bind(this);

    this.state = {
      open: false,
      fadeOut: false,
      fullName: '',
      fullNameValid: true,
      fullNameMessage: '',
      email: '',
      emailValid: true,
      emailMessage: '',
    };
  }

  handleSubmit(e) {
    e.preventDefault();
    const valid = this.validate();
    if (valid) {
      api.getCSRFTokenFromApi()
      .then(token => {
        this.refs.authToken.value = token;
        this.refs.signupForm.submit();
      })
      .catch(console.error);
    }
  }
  
  toggleDialog() {
    this.setState({open: !this.state.open});
  }

  updateEmail(e) {
    this.setState({
      email: e.target.value
    });
  }
  
  updateFullName(e) {
    this.setState({
      fullName: e.target.value
    });
  }

  validate() {
    let valid = true;
    if (this.state.fullName.length === 0) {
      this.setState({fullNameValid: false, fullNameMessage: 'is required'});
      valid = false;
    } else {
      this.setState({fullNameValid: true, fullNameMessage: ''});
    }

    if (!validator.isEmail(this.state.email)) {
      this.setState({emailValid: false, emailMessage: 'is not a valid email address'});
      valid = false;
    } else {
      this.setState({emailValid: true, emailMessage: ''});
    }
    return valid;
  }

  render() {
    const signupDialog = (
        <Dialog 
          dismissDialog={() => this.setState({open: false})}
          key="signupdialog"
          open={this.state.open}
          title={'Please complete the following to continue:'}
          style={{fontSize: '16px', textAlign: 'center'}}
          overlayClassName="overlay"
          overlayStyle={{
            width: '450px',
            top: '50%'
          }}
        >
          <form className="simple_form user-form form-compact disable-on-submit text-left" ref="signupForm" action={this.props.submit_action} acceptCharset="UTF-8" method="post" >
            <input name="utf8" type="hidden" value="&#x2713;" />
            <input name="redirect_to" type="hidden" value={this.props.redirect_to} />
            <input name="source" type="hidden" value={this.props.source} />
            <input type="hidden" name="authenticity_token" ref="authToken" />
    
            <TextInput 
              focus={true}
              label="First and last name"
              message={this.state.fullNameMessage}
              name="user[full_name]"
              valid={this.state.fullNameValid}
              onChange={this.updateFullName}
            />
            <TextInput
              type="email"
              label="Email"
              name="user[email]"
              message={this.state.emailMessage}
              valid={this.state.emailValid}
              onChange={this.updateEmail}
            />
            <Button type="submit" className="btn-primary btn-block" onClick={this.handleSubmit}>Continue</Button>
        </form>
        <p style={{marginBottom: '0'}}><small>Already have an account? <a className="sign-in-link show-login-form" href={'/users/sign_in?redirect_to=' + encodeURIComponent(this.props.redirect_to)}>Sign in</a></small></p>
      </Dialog>
    );
    
    return (
      <div>
        <Button className={this.props.buttonClass} onClick={this.toggleDialog}>Register as a participant</Button>
        <ReactCSSTransitionGroup transitionName="fadein" transitionEnterTimeout={450} transitionLeaveTimeout={450}>
          {this.state.open ? signupDialog : null}
        </ReactCSSTransitionGroup>
      </div>
    );
  }
}

SignupForm.propTypes = {
  buttonClass: PropTypes.string,
  redirect_to: PropTypes.string,
  source: PropTypes.string,
  submit_action: PropTypes.string
};


export default SignupForm;
