import React, { Component, PropTypes } from 'react';
import ReactDOM from 'react-dom';
import ReactCSSTransitionGroup from 'react-addons-css-transition-group';

export default class ErrorMessage extends Component {
  constructor(props) {
    super(props);

    this.handleDismiss = this.handleDismiss.bind(this);
  }

  componentDidMount() {
    this.timeout = setTimeout(() => {
      this.handleDismiss();
    }, 5000);
  }

  componentWillUnmount() {
    window.clearTimeout(this.timeout);
  }

  handleDismiss() {
    this.props.dismiss();
  }

  render() {
    const { msg, type } = this.props.state;

    return (
      <ReactCSSTransitionGroup transitionName="error-message" transitionEnterTimeout={500} transitionLeaveTimeout={300} transitionAppear={true} transitionAppearTimeout={500}>
        <div key={msg} className="react-editor-error-message">
          <div className={type === 'success' ? 'alert-success' : 'alert-danger'}>
            <div className="error-message-body">
              <span>{msg}</span>
              <button className="error-message-close-button" onClick={this.handleDismiss}>×</button>
            </div>
          </div>
        </div>
      </ReactCSSTransitionGroup>
    );
  }
}

ErrorMessage.PropTypes = {
  dismiss: PropTypes.func.isRequired,
  state: PropTypes.object.isRequired
};