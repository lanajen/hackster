import React from 'react';
import ListsDropdown from './components/ListsDropdown';
import { fetchLists } from '../utils/ReactAPIUtils';

const App = React.createClass({

  getInitialState() {
    return {
      lists: [],
      isDropdownOpen: false,
      isLoading: false,
      isLoaded: false
    };
  },

  onListButtonClick() {
    this.setState({
      isDropdownOpen: !this.state.isDropdownOpen
    });

    if (!this.state.isLoading && !this.state.isLoaded) {
      let promise = fetchLists(this.props.projectId);
      this.setState({
        isLoading: true
      });

      promise.then(function(response) {
        let lists = response.body.lists;

        this.setState({
          isLoading: false,
          isLoaded: true,
          lists: lists
        });
      }.bind(this)).catch(function(err) { console.log('Request Error: ' + err); });
    }
  },

  render: function() {

    return (
      <div className='lists-dropdown'>
        <a href="javascript:void(0)" className="btn btn-block btn-default btn-ellipsis toggle-lists-btn" onClick={this.onListButtonClick}>
          <i className="fa fa-bookmark-o"></i>
          <span>Add to my lists</span>
        </a>
        <ListsDropdown lists={this.state.lists} isOpen={this.state.isDropdownOpen} isLoading={this.state.isLoading} {...this.props} />
      </div>
    );
  }

});

export default App;