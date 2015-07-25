import React from 'react';
import { flagContent } from '../utils/ReactAPIUtils';

const App = React.createClass({

  getInitialState() {
    return {
      flagged: false,
      isLoading: false
    };
  },

  componentDidMount() {
    // Activates the tooltip.
    if(window) {
      window.$('[data-toggle="tooltip"]').tooltip();
    }
  },

  componentWillUnmount() {
    // Cleans up any listeners.
    if(window) {
      window.$('[data-toggle="tooltip"]').tooltip('destroy');
    }
  },

  componentDidUpdate(prevProps, prevState) {
    if (window && prevState.flagged != this.state.flagged) {
      let btn = window.$(this.refs.btn.getDOMNode());
      btn.tooltip('hide');
      btn.attr('data-original-title', btn.attr('title'));
      btn.tooltip('fixTitle');
      btn.tooltip('show');
    }
  },

  onFlagButtonClick() {
    if (!this.state.isLoading && !this.state.flagged) {
      let promise = flagContent(this.props.flaggable.type, this.props.flaggable.id, this.props.currentUserId);
      this.setState({
        isLoading: true
      });

      promise.then(function(response) {
        this.setState({
          isLoading: false,
          flagged: true
        });
      }.bind(this)).catch(function(err) { console.log('Request Error: ' + err); });
    }
  },

  render: function() {
    let icon = this.state.isLoading ? (<i className="fa fa-spin fa-spinner"></i>) :
                                      (this.state.flagged ? (<i className="fa fa-flag"></i>) :
                                      (<i className="fa fa-flag-o"></i>));
    let toolTipTitle = this.state.flagged ? 'Flagged for spam' : 'Flag this for spam';

    return (
      <a href="javascript:void(0)" title={toolTipTitle} rel="tooltip" data-toggle="tooltip" data-placement='top' data-container='body' onClick={this.onFlagButtonClick} className='flag-btn' ref="btn">
        {icon}
      </a>
    );
  }

});

export default App;