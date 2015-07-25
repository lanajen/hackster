import React from 'react';
import _ from 'lodash';
import htmlparser from 'htmlparser';
import select from 'selection-range';

const ContentEditable = React.createClass({

  componentDidMount() {
    if(document) {
      let node = React.findDOMNode(this);
      // let range = document.createRange();
      // let sel = document.getSelection();

      if(this.props.cursorPos === null) {
        // node.focus();
        // range.selectNodeContents(node);
        // // PUT CURSOR AT CURRENT POSITION?
        // range.collapse(false);
        // sel.removeAllRanges();
        // sel.addRange(range);
        // range.detach();
      } else {
        getCursor().restoreSelection(node, this.props.cursorPos);
      }
    }
  },

  componentDidUpdate() {
    if ( this.props.html !== React.findDOMNode(this).innerHTML ) {
     React.findDOMNode(this).innerHTML = this.props.html;
    }
  },

  shouldComponentUpdate(nextProps, nextState){
    return nextProps.html !== React.findDOMNode(this).innerHTML;
  },

  emitChange(e){
    let html = React.findDOMNode(this).innerHTML;
    this.saveCursorPosition();

    if (this.props.onChange && html !== this.lastHtml) {
      this.props.onChange(html);
    }
    this.lastHtml = html;
  },

  onBlur(e) {
    e.preventDefault();
    e.stopPropagation();
    let html = React.findDOMNode(this).textContent;
    this.props.onBlur(e, html);
  },

  onKeyPress(e) {
    if(e.key === 'Enter') {
      e.preventDefault();
      e.stopPropagation();
      let html = React.findDOMNode(this).innerHTML;
      this.props.onEnterKey(html);
    }

    // this.saveCursorPosition('increment');
  },

  onKeyDown(e) {
    if(document) {
      let node = React.findDOMNode(this);
      // let range = window.getSelection().getRangeAt(0);
      // let preSelectionRange = range.cloneRange();
      // preSelectionRange.selectNodeContents(node);
      // preSelectionRange.setEnd(range.startContainer, range.startOffset);
      // let start = preSelectionRange.toString().length;
      // let end = start + range.toString.length;
    }
  },

  saveCursorPosition() {
    let cursor = getCursor().saveSelection(React.findDOMNode(this));
    console.log(cursor);
    this.props.onCursorPos(cursor);
  },

  render(){
    // console.log('CE', this.props);
    return (
      <div key={this.props.refLink}
        ref={this.props.refLink}
        style={this.props.style || null}
        className={this.props.textAreaClasses || null}
        onInput={this.emitChange} 
        onBlur={this.onBlur}
        onKeyPress={this.onKeyPress}
        onKeyDown={this.onKeyDown}
        contentEditable={true}
        dangerouslySetInnerHTML={{__html: this.props.html }}></div>
    );
  }
});

function getCursor() {
  var saveSelection, restoreSelection;

  if (window.getSelection && document.createRange) {
      saveSelection = function(containerEl) {
          var range = window.getSelection().getRangeAt(0);
          var preSelectionRange = range.cloneRange();
          preSelectionRange.selectNodeContents(containerEl);
          preSelectionRange.setEnd(range.startContainer, range.startOffset);
          var start = preSelectionRange.toString().length;

          return {
              start: start,
              end: start + range.toString().length
          };
      };

      restoreSelection = function(containerEl, savedSel) {
          var charIndex = 0, range = document.createRange();
          range.setStart(containerEl, 0);
          range.collapse(true);
          var nodeStack = [containerEl], node, foundStart = false, stop = false;

          while (!stop && (node = nodeStack.pop())) {
              if (node.nodeType == 3) {
                  var nextCharIndex = charIndex + node.length;
                  if (!foundStart && savedSel.start >= charIndex && savedSel.start <= nextCharIndex) {
                      range.setStart(node, savedSel.start - charIndex);
                      foundStart = true;
                  }
                  if (foundStart && savedSel.end >= charIndex && savedSel.end <= nextCharIndex) {
                      range.setEnd(node, savedSel.end - charIndex);
                      stop = true;
                  }
                  charIndex = nextCharIndex;
              } else {
                  var i = node.childNodes.length;
                  while (i--) {
                      nodeStack.push(node.childNodes[i]);
                  }
              }
          }

          var sel = window.getSelection();
          sel.removeAllRanges();
          sel.addRange(range);
      }
  } else if (document.selection) {
      saveSelection = function(containerEl) {
          var selectedTextRange = document.selection.createRange();
          var preSelectionTextRange = document.body.createTextRange();
          preSelectionTextRange.moveToElementText(containerEl);
          preSelectionTextRange.setEndPoint("EndToStart", selectedTextRange);
          var start = preSelectionTextRange.text.length;

          return {
              start: start,
              end: start + selectedTextRange.text.length
          }
      };

      restoreSelection = function(containerEl, savedSel) {
          var textRange = document.body.createTextRange();
          textRange.moveToElementText(containerEl);
          textRange.collapse(true);
          textRange.moveEnd("character", savedSel.end);
          textRange.moveStart("character", savedSel.start);
          textRange.select();
      };
  }

  return {
    saveSelection: saveSelection,
    restoreSelection: restoreSelection
  }
}

export default ContentEditable;