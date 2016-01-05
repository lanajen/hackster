import React from 'react';
import { flagContent } from '../utils/ReactAPIUtils';

const App = React.createClass({

  getInitialState() {
    return {
      flagged: false,
      isLoading: false
    };
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
    let toolTipTitle = this.state.flagged ? 'Flagged' : 'Flag as inappropriate';

    let icon = this.state.isLoading ? (<i className="fa fa-spin fa-spinner"></i>) :
                                      toolTipTitle;

    return (
      <a href="javascript:void(0)" onClick={this.onFlagButtonClick} className='flag-btn' ref="btn">
        {icon}
      </a>
    );
  }

});

export default App;