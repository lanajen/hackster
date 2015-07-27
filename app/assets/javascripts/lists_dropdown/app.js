import React from 'react';
import ListsDropdown from './components/ListsDropdown';
import ListsStore from './stores/ListsStore';

const App = React.createClass({

  getInitialState() {
    return {
      isDropdownOpen: false
    };
  },

  handleListButtonClick() {
    this.setState({
      isDropdownOpen: !this.state.isDropdownOpen
    });

    if (!ListsStore.isPopulated) {
      ListsStore.populateStore(this.props.projectId);
    }
  },

  render: function() {

    return (
      <div className='lists-dropdown'>
        <a href="javascript:void(0)" className="btn btn-block btn-default btn-ellipsis toggle-lists-btn" onClick={this.handleListButtonClick}>
          <i className="fa fa-bookmark-o"></i>
          <span>Add to my lists</span>
        </a>
        <ListsDropdown isOpen={this.state.isDropdownOpen} {...this.props} />
      </div>
    );
  }

});

export default App;