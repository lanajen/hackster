import React from 'react';
import ListItem from './ListItem';
import _ from 'lodash';

var ListsDropdown = React.createClass({

  onInputClick: function(e) {

  },

  render: function() {
    let projectId = this.props.projectId;
    let lists = _.map(this.props.lists, function(list, index) {
      return (
        <ListItem key={index} list={list} projectId={projectId} />
      );
    });

    if(!lists.length) {
      lists = (<li className="list-item">Looks like a good time to <a href="/lists/new" target='_blank'>create your first list</a>.</li>);
    }

    if(this.props.isLoading) {
      lists = (<i className="fa fa-spinner fa-3x fa-spin lists-loading-icon text-center"></i>);
    }

    let style = this.props.isOpen ? {} : { display: 'none' };

    return (
      <div className="list-group-wrapper" style={style}>
        <ul className="list-group">
          {lists}
        </ul>
        <div className="list-group-footer">
          <a href={this.props.path}>View More</a>
        </div>
      </div>
    );
  }

});

export default ListsDropdown;