import React from 'react';

const WidgetPlaceholder = React.createClass({

  getInitialState() {
    return {
      hovered: false
    };
  },

  toggleHover(hovered) {
    this.setState({
      hovered: hovered
    });
  },

  handleWidgetDeletion() {
    this.props.deleteWidget(this.props.storeIndex);
  },

  render: function() {
    let data = this.props.widgetData;
    let widgetTypes = {
      'parts_widget': 'Parts List',
      'bitbucket-widget': 'Bitbucket Repo',
      'github-widget': 'Github Repo',
      'old_code_widget': 'Old Code Widget',
      'twitter': 'Tweet'
    };

    let type = <span className="text-danger">{widgetTypes[data.widgetType]}</span>
    let tweet = <span style={{ color: 'lightblue' }}>tweet</span>

    let placeholder = data.widgetType === 'twitter'
                    ? (<h3><span style={{color: 'lightblue'}} className="reit-button fa fa-twitter"/> Your {tweet} will display here.</h3>)
                    : (<h3>Apologies, {type} is now deprecated in the Story section.</h3>);

    let content = this.state.hovered
                ? (<button style={{ fontSize: '1.25em' }} className="fa fa-trash-o btn btn-danger" onClick={this.handleWidgetDeletion}></button>)
                : (placeholder);

    return (<div className="react-editor-widget-placeholder" data-hash={this.props.hash} onMouseEnter={this.toggleHover.bind(this, true)} onMouseLeave={this.toggleHover.bind(this, false)}>
              {content}
            </div>);
  }

});

export default WidgetPlaceholder;