import React from 'react';
import Utils from '../utils/DOMUtils';

const FigCaption = React.createClass({

  handleInput(e) {
    let html = React.findDOMNode(e.target).textContent;
    this.props.setFigCaptionText(html);
  },

  handleKeyDown(e) {
    let node = React.findDOMNode(e.target);
    let arrowKeys = {
      '37': true,
      '38': true,
      '39': true,
      '40': true
    };

    if(node.textContent === 'caption (optional)' && !arrowKeys[e.keyCode]) {
      node.textContent = '';
    } else if(e.keyCode === 8 && node.textContent.length <= 1) {
      node.textContent = 'caption (optional)';
    }

    switch(e.keyCode || e.charCode) {
      case 13: // ENTER
        this.props.handleFigCaptionKeys(e, 'Enter');
        break;
    default: 
      break;
    }
  },

  render() {
    return (
      <figcaption className={this.props.className}
                  style={this.props.style}
                  onInput={this.handleInput}
                  onKeyDown={this.handleKeyDown}
                  contentEditable={true} 
                  dangerouslySetInnerHTML={{__html: this.props.html}}>
      </figcaption>
    );
  }

});

export default FigCaption;