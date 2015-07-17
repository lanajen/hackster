import React from 'react';
import _ from 'lodash';
import ContentEditable from '../../reusable_components/ContentEditable';
import { createRandomNumber } from '../../utils/Helpers';

const Paragraph = React.createClass({
  
  getInitialState() {
    return {
      editable: false,
      nodeContent: 'starter'
    };
  },

  onContentEditableChange(html) {
    this.setState({
      nodeContent: html
    });
  },

  onClick(e) {
    e.preventDefault();
    e.stopPropagation();

    this.setState({
      editable: true
    });
  },

  onKeyPress(e) {
    if(e.key === 'Enter') {
      this.setState({
        editable: false
      });
    }
  },

  componentWillRecieveProps(nextProps) {
    if(nextProps.editable !== this.state.editable) {
      this.setState({
        editable: nextProps.editable
      });
    }
  },

  render() {
    let content = this.state.editable ? (<ContentEditable refLink={createRandomNumber()} html={this.state.nodeContent} onChange={this.onContentEditableChange} onKeyPress={this.onKeyPress}/>) : 
                                        (<p onClick={this.onClick}>{this.state.nodeContent}</p>);

    return (
      <p>{this.props.content}</p>
    );
  };
});

const Editable = React.createClass({

  getInitialState() {
    return {
      json: [{tag: 'p', content: 'First Parent'}]
    };
  },

  onWrapperClick() {
    // Add in a paragraph element for each new row.  Listen for carriage returns to create new parent elements.
    
  },

  createLayout(json) {

  },

  render() {
    // Recurse through JSON and create react elements.
    let content = _.map(this.state.json, function(el) {
      if(el.tag === p) {
        return <Paragraph content={el.content}></Paragraph>;
      }
    });
    return (
      <div className="box-content" onClick={this.onWrapperClick}>
        {content}
      </div>
    );
  }

});

export default Editable;