import React from 'react';
import ReactDOM from 'react-dom';
import ListsStore from './../stores/ListsStore';
import postal from 'postal';
import _ from 'lodash';

const channel = postal.channel('lists');

const ListForm = React.createClass({

  getInitialState: function() {
    return {
      canSubmit: false,
      isLoading: false
    }
  },

  componentWillMount() {
    this.updateSub = channel.subscribe('store.changed', function(store) {
      this.setState({
        canSubmit: false,
        isLoading: false
      });
      ReactDOM.findDOMNode(this.refs.name).value = '';
    }.bind(this));
  },

  componentWillUnmount: function() {
    this.updateSub.unsubscribe();
  },

  handleInputChange: function(e) {
    let canSubmit;
    if (e.target.value.length > 0) {
      canSubmit = true;
    } else {
      canSubmit = false;
    }
    this.setState({
      canSubmit: canSubmit
    });
  },

  handleSubmit: function(e) {
    e.preventDefault();
    let name = ReactDOM.findDOMNode(this.refs.name).value;
    if (this.state.canSubmit) {
      ListsStore.addList(name);
      this.setState({
        canSubmit: false,
        isLoading: true
      })
    }
  },

  render: function() {
    let button = this.state.isLoading ? (<i className="fa fa-spinner fa-spin"></i>) : (<span>Create</span>);
    let placeholder = this.props.placeholder || 'New list name (eg: "To Do")';

    return (
      <form onSubmit={this.handleSubmit}>
        <div className='input-group'>
          <input type='text' ref='name' className='form-control' placeholder={placeholder} onChange={this.handleInputChange} />
          <span className='input-group-btn'>
            <button disabled={!this.state.canSubmit} className='btn btn-primary'>{button}</button>
          </span>
        </div>
      </form>
    );
  }

});

export default ListForm;