import React from 'react';
import _ from 'lodash';
import { toggleProjectInList } from '../../utils/ReactAPIUtils';

const ListItem = React.createClass({

  getInitialState: function(){
    return {
      isChecked: this.props.list.isInitiallyChecked,
      isLoading: false,
      showCheckmark: false,
      checkmarkOpacity: 1
    };
  },

  handleInputChange: function(e) {
    if (!this.state.isLoading) {
      let requestType = e.target.checked ? 'POST' : 'DELETE';
      let promise = toggleProjectInList(requestType, this.props.list.id, this.props.projectId);
      this.setState({
        isLoading: true
      });

      promise.then(function(response) {
        this.setState({
          isLoading: false,
          showCheckmark: true,
          isChecked: !this.state.isChecked
        });
        window.setTimeout(function(){
          this.setState({
            checkmarkOpacity: 0.01
          });
          window.setTimeout(function(){
            this.setState({
              showCheckmark: false,
              checkmarkOpacity: 1
            });
          }.bind(this), 500);
        }.bind(this), 2000);
      }.bind(this)).catch(function(err) {
        this.setState({
          isLoading: false,
          isChecked: this.state.isChecked
        });
        console.log('Request Error: ' + err);
      }.bind(this));
    }
  },

  render: function() {
    let list = this.props.list;

    let progress;
    if (this.state.showCheckmark) {
      progress = (<i ref="check" className='fa fa-check' style={{opacity: this.state.checkmarkOpacity}}></i>);
    } else if (this.state.isLoading) {
      progress = (<i className='fa fa-spinner fa-spin'></i>);
    }
    return (
      <li className='list-item'>
        <label>
          <input type='checkbox' name='lists' checked={this.state.isChecked} onChange={this.handleInputChange} />
          <span dangerouslySetInnerHTML={{__html: list.name}}></span>
        </label>
        {progress}
      </li>
    );
  }

});

export default ListItem;