import React from 'react';
import { updateChallengeRegistration } from '../utils/ReactAPIUtils';

const App = React.createClass({

  getInitialState() {
    return {
      checkmarkOpacity: 1,
      isLoading: false,
      showSaved: false,
      subscribed: false
    };
  },

  handleClick(e) {
    if (!this.state.isLoading) {
      const checked = e.target.checked;
      let promise = updateChallengeRegistration(this.props.challengeId, { challenge_registration: { receive_sponsor_news: checked }});
      this.setState({
        isLoading: true,
        subscribed: checked
      });

      promise.then(function(response) {
        this.setState({
          showSaved: true,
          isLoading: false
        });
        window.setTimeout(function(){
          this.setState({
            checkmarkOpacity: 0.01
          });
          window.setTimeout(function(){
            this.setState({
              checkmarkOpacity: 1,
              showSaved: false
            });
          }.bind(this), 150);
        }.bind(this), 2000);

      }.bind(this)).catch(function(err) {
        console.log('Request Error: ' + err);
        this.setState({
          isLoading: false,
          subscribed: !checked
        });
      }.bind(this));
    }
  },

  render: function() {
    let saved;
    if (this.state.showSaved) {
      saved = (
        <div className="saved text-success" style={{opacity: this.state.checkmarkOpacity}}>
          <i className='fa fa-check'></i>
          <span>Saved</span>
        </div>
      );
    }
    return (
      <label className="checkbox challenge-subscribe-button">
        <input type='checkbox' checked={this.state.subscribed} onClick={this.handleClick} />
        <span>{this.props.label}</span>
        {saved}
      </label>
    );
  }

});

export default App;