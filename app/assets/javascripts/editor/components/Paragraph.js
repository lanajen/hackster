import React from 'react';
import _ from 'lodash';
import ContentEditable from '../../reusable_components/ContentEditable';
import { createRandomNumber } from '../../utils/Helpers';

const Paragraph = React.createClass({
  
  getInitialState() {
    return {
      editable: false,
      nodeContent: '',
      html: '',
      cursorPos: null
    };
  },

  componentWillMount() {
    this.setState({
      nodeContent: this.props.content,
      editable: this.props.editable
    });
  },

  onContentEditableChange(html) {
    // Strip text from html.
    // console.log(html);
    this.setState({
      html: html
    });
  },

  onClick(e) {
    e.preventDefault();
    e.stopPropagation();


    if(this.state.editable === false)  {
      let html = React.findDOMNode(this).innerHTML;

      this.setState({
        editable: true,
        html: html
      });
    }
  },

  click(x,y){
    if(this.state.editable === false) {
      var ev = new MouseEvent('click', {
        view: window,
        clientX: x,
        clientY: y,
        bubbles: false,
        cancelable: true
      });
      document.elementFromPoint(x,y).dispatchEvent(ev);
    }
  },

  onBlur(e, html) {
    // console.log(e, html);
    // this.props.onBlur(html);

    if(this.state.editable === true) {
      this.setState({
        editable: false
      });
    }
  },

  onEnterKey() {
    this.props.onEnterKey();
  },

  onCursorPos(start, end) {
    this.setState({
      cursorPos: start
    });
  },

  componentWillRecieveProps(nextProps) {
    if(nextProps.editable !== this.state.editable) {
      this.setState({
        editable: nextProps.editable
      });
    }
  },

  onBlockItemChange(e) {
    console.log('SELECTED');
  },

  render() {
    let content = this.state.editable ? (<ContentEditable key={createRandomNumber()} ref={this.props.refLink} refLink={createRandomNumber()} className="no-outline-focus" html={this.state.html} data-index-pos={this.props.indexPos} cursorPos={this.state.cursorPos} onBlur={this.onBlur} onChange={this.onContentEditableChange} onEnterKey={this.onEnterKey} onCursorPos={this.onCursorPos}/>) : 
                                        (<p key={createRandomNumber()} style={{margin: 0}} ref={this.props.refLink} template={'<p>hi</p>'} data-index-pos={this.props.indexPos} onChange={this.onBlockItemChange} onClick={this.onClick}>{this.props.content} {this.props.children}</p>); 
    return (
      <div style={{margin: 0}} onMouseDown={this.onMouseDown}>
        {content}
      </div>
    );
  }
});

export default Paragraph;