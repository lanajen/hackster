import React from 'react';
import _ from 'lodash';
import htmlparser from 'htmlparser';
import select from 'selection-range';

const ContentEditable = React.createClass({

    shouldComponentUpdate(nextProps, nextState){
      return nextProps.html !== React.findDOMNode(this).innerHTML;
    },

    componentDidUpdate(prevProps) {
      // When we force a beginning p element in emitChange, the componentUpdates and we lose focus.  This will reset the focus to the end.
      // This should happen only when we force an initial p element.
      if(prevProps.html !== this.props.html) {
        if(document) {
          let node = React.findDOMNode(this);
          let range = document.createRange();
          let sel = document.getSelection();

          node.focus();
          range.selectNodeContents(node);
          range.collapse(false);
          sel.removeAllRanges();
          sel.addRange(range);
          range.detach();
        }
      }
    },

    emitChange(e){
      let html = React.findDOMNode(this).innerHTML;
      // Forces a paragraph when there's no content or user deletes all content.  This is to prevent a starting 'text' element.
      if(html.length === 1) {
        html = '<p>' + html + '</p>';
      }
      this.props.onChange(html);
    },

    render(){
      // console.log('CE', this.props);
      return (
        <div key={this.props.refLink}
          ref={this.props.refLink}
          style={this.props.style || null}
          id="contenteditable"
          className={this.props.textAreaClasses || null}
          onInput={this.emitChange} 
          onBlur={this.emitChange}
          contentEditable={true}
          dangerouslySetInnerHTML={{__html: this.props.html }}></div>
      );
    }
});

export default ContentEditable;