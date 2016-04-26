import React, { Component, PropTypes } from 'react';
import ReactCSSTransitionGroup from 'react-addons-css-transition-group';

export default class Messenger extends Component {
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
    this.props.dismiss({'open': false, 'msg': '', 'type': 'error'});
  }

  render() {
    const { messenger } = this.props;

    if(!messenger.open) return null;

    return (
      <ReactCSSTransitionGroup transitionName="messenger" transitionEnterTimeout={500} transitionLeaveTimeout={300} transitionAppear={true} transitionAppearTimeout={500}>
        <div key={messenger.msg} className="mouser-messenger">
          <div className={messenger.type === 'success' ? 'alert-success' : 'alert-danger'}>
            <div className="messenger-body">
              <span>{messenger.msg}</span>
              <button className="messenger-close-button" onClick={this.handleDismiss}>×</button>
            </div>
          </div>
        </div>
      </ReactCSSTransitionGroup>
    );
  }
}

Messenger.PropTypes = {
  dismiss: PropTypes.func.isRequired,
  messenger: PropTypes.object.isRequired
};