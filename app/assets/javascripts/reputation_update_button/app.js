import React from 'react';
import { checkJob, launchJob } from '../utils/ReactAPIUtils';

const App = React.createClass({

  getInitialState() {
    return {
      isLoading: false,
      hasUpdated: false,
      timeAgo: (this.props.timestamp ? moment.unix(this.props.timestamp).fromNow() : null)
    };
  },

  handleButtonClick() {
    if (!this.state.isLoading && !this.state.hasUpdated) {
      let promise = launchJob('compute_reputation');
      this.setState({
        isLoading: true
      });

      promise.then(function(response) {
        this.checkJob(response.body.job_id);
      }.bind(this)).catch(function(err) { console.log('Request Error: ' + err); });
    }
  },

  checkJob(jobId) {
    let promise = checkJob(jobId);

    promise.then(function(response) {
      console.log('RESPONSE', response);
      if (response.body.status == 'complete') {
        this.setState({
          isLoading: false,
          hasUpdated: true,
          timeAgo: 'just now (page will refresh)'
        });
        window.setTimeout(function(){
          window.location.reload();
        }, 2500);
      } else {
        window.setTimeout(function(){
          this.checkJob(jobId);
        }.bind(this), 1000);
      }
    }.bind(this)).catch(function(err) { console.log('Request Error: ' + err); });
  },

  render: function() {
    let action, lastUpdate;
    if (this.state.timeAgo) {
      lastUpdate = (<span>Last updated <strong>{this.state.timeAgo}</strong>. </span>);
    }

    if (!this.state.hasUpdated) {
      action = this.state.isLoading ? (<span><i className="fa fa-spin fa-spinner"></i> Updating...</span>) :
                                      (<a href="javascript:void(0)" onClick={this.handleButtonClick}>Update now.</a>);
    }

    return (
      <span>
        {lastUpdate}
        {action}
      </span>
    );
  }

});

export default App;