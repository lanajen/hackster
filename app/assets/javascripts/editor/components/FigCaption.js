import React from 'react';

const FigCaption = React.createClass({

  /** Easier to use state here than updating the cursor on every input. */
  getInitialState() {
    return {
      html: null
    };
  },

  componentWillMount() {
    this.setState({
      html: this.props.html
    });
  },

  handleInput(e) {
    let html = React.findDOMNode(e.target).textContent;
    this.setState({
      html: html
    });
  },

  handleBlur() {
    this.props.setFigCaptionText(this.state.html);
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

  handleKeyUp() {
    /** Input handler for IE. */
    if(this.props.isIE) {
      let html = React.findDOMNode(e.target).textContent;
      this.setState({
        html: html
      });
    }
  },

  render() {
    /** 
      * We keep the main source of truth (this.props.html) coming from the reducer. 
      * State is only held here to update the reducer once the component loses focus.
      * This way the cursor stays where we want it and doesn't jump around on rerenders.
      */
    return (
      <figcaption className={this.props.className}
                  style={this.props.style}
                  onInput={this.handleInput}
                  onBlur={this.handleBlur}
                  onKeyDown={this.handleKeyDown}
                  onKeyUp={this.handleKeyUp}
                  contentEditable={true} 
                  dangerouslySetInnerHTML={{__html: this.props.html}}>
      </figcaption>
    );
  }

});

export default FigCaption;