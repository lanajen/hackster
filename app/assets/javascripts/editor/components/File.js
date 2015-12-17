import React from 'react';

var File = React.createClass({

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

  handleDeleteClick(e) {
    e.preventDefault();
    this.props.actions.deleteComponent(this.props.storeIndex);
  },

  render() {
    let content = this.state.hovered
                     ? (<button style={{ fontSize: '1.25em' }} className="fa fa-trash-o btn btn-danger" onClick={this.handleDeleteClick}></button>)
                     : (<span>
                          <i className="fa fa-file-o fa-2x"></i>
                          <a href={this.props.fileData.url}>{this.props.fileData.content}</a>
                        </span>);
    return (
      <div className="react-editor-file" data-hash={this.props.hash} onMouseEnter={this.toggleHover.bind(this, true)} onMouseLeave={this.toggleHover.bind(this, false)}>
        {content}
      </div>
    );
  }

});

export default File;