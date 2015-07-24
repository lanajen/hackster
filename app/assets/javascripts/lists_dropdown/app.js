import React from 'react';
import ListsDropdown from './components/ListsDropdown';
import ListsStore from './stores/ListsStore';
import injectTapEventPlugin from 'react-tap-event-plugin';
injectTapEventPlugin();

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

  handleListFormSubmit(listName) {
    ListsStore.addList(listName);
  },

  render: function() {

    return (
      <div className='lists-dropdown'>
        <a href="javascript:void(0)" className="btn btn-block btn-default btn-ellipsis toggle-lists-btn" onClick={this.handleListButtonClick}>
          <i className="fa fa-bookmark-o"></i>
          <span>Add to my lists</span>
        </a>
        <ListsDropdown isOpen={this.state.isDropdownOpen} onFormSubmit={this.handleListFormSubmit} {...this.props} />
      </div>
    );
  }

});

export default App;