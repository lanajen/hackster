import React from 'react';
import { IconButton } from 'material-ui';

const WidgetPlaceholder = React.createClass({

  handleWidgetDeletion() {
    this.props.deleteWidget(this.props.storeIndex);
  },

  render: function() {
    let data = this.props.widgetData;
    let widgetTypes = {
      'parts_widget': 'Parts List',
      'bitbucket-widget': 'Bitbucket Repo',
      'github-widget': 'Github Repo'
    };

    let type = <span className="text-danger">{widgetTypes[data.widgetType]}</span>

    return (
      <div className="react-editor-widget-placeholder">
        <h3>Apologies, {type} is now deprecated in the Story section.</h3>
        <IconButton iconStyle={{color: '#a94442'}} iconClassName="reit-button fa fa-trash-o" tooltip="Delete" onClick={this.handleWidgetDeletion}/>
      </div>
    );
  }

});

export default WidgetPlaceholder;