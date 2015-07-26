import React from 'react';
import postal from 'postal';
import _ from 'lodash';

const channel = postal.channel('lists');

const ListForm = React.createClass({

  getInitialState: function() {
    return {
      canSubmit: false,
      inputValue: '',
      isLoading: false
    }
  },

  componentWillMount() {
    this.updateSub = channel.subscribe('store.changed', function(store) {
      this.clearInput();
    }.bind(this));
  },

  componentWillUnmount: function() {
    this.updateSub.unsubscribe();
  },

  clearInput: function() {
    this.setState({
      canSubmit: false,
      inputValue: '',
      isLoading: false
    });
  },

  handleInputChange: function(e) {
    let canSubmit;
    if (e.target.value.length > 0) {
      canSubmit = true;
    } else {
      canSubmit = false;
    }
    this.setState({
      canSubmit: canSubmit,
      inputValue: e.target.value
    });
  },

  handleSubmit: function(e) {
    e.preventDefault();
    let name = React.findDOMNode(this.refs.name).value;;
    if (this.state.canSubmit) {
      this.props.onSubmit(name);
      this.setState({
        canSubmit: false,
        isLoading: true
      })
    }
  },

  render: function() {
    let button = this.state.isLoading ? (<i className="fa fa-spinner fa-spin"></i>) : (<span>Create</span>);

    return (
      <form onSubmit={this.handleSubmit}>
        <div className='input-group'>
          <input type='text' ref='name' className='form-control' placeholder='Name of new list' value={this.state.inputValue} onChange={this.handleInputChange} />
          <span className='input-group-btn'>
            <button disabled={!this.state.canSubmit} className='btn btn-primary'>{button}</button>
          </span>
        </div>
      </form>
    );
  }

});

export default ListForm;