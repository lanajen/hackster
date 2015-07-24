import React from 'react';
import ListItem from './ListItem';
import ListForm from './ListForm';
import postal from 'postal';
import _ from 'lodash';

const channel = postal.channel('lists');

var ListsDropdown = React.createClass({

  getInitialState() {
    return {
      lists: [],
      isLoading: true
    };
  },

  componentWillMount() {
    this.initialSub = channel.subscribe('initial.store', function(store) {
      this.setLists(store);
    }.bind(this));

    this.updateSub = channel.subscribe('store.changed', function(store) {
      this.setLists(store);
    }.bind(this));
  },

  componentWillUnmount: function() {
    this.initialSub.unsubscribe();
    this.updateSub.unsubscribe();
  },

  handleFormSubmit: function(name) {
    this.props.onFormSubmit(name);
  },

  render: function() {
    let projectId = this.props.projectId;
    let lists = _.map(this.state.lists, function(list, index) {
      return (
        <ListItem key={index} list={list} projectId={projectId} />
      );
    });

    if (this.state.isLoading) {
      lists = (
        <li className="list-item text-center">
          <i className="fa fa-spinner fa-3x fa-spin"></i>
        </li>
      );
    }

    let style = this.props.isOpen ? {} : { display: 'none' };

    return (
      <div className="list-group-wrapper" style={style}>
        <ul className="list-group">
          {lists}
          <li className="list-item">
            <ListForm isLoading={this.state.isFormLoading} onSubmit={this.handleFormSubmit} />
          </li>
        </ul>
      </div>
    );
  },

  setLists(store) {
    this.setState({
      lists: store,
      isLoading: false,
      isLoaded: false
    });
  },

});

export default ListsDropdown;