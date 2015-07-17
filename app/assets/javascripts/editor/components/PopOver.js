import React from 'react';

const PopOver = React.createClass({

  componentWillMount() {
    if(document) {
      document.addEventListener('click', this.onBodyClick, false);
    }
  },

  componentWillUnmount() {
    if(document) {
      document.removeEventListener('click', this.onBodyClick, false);
    }
  },

  componentDidMount() {
    console.log('mounted');
    React.findDOMNode(this.refs.input).focus();
  },

  onBodyClick(e) {
    if(e.target !== React.findDOMNode(this.refs.input) && e.target !== React.findDOMNode(this.refs.popOver)) {
      this.props.unMountPopOver();
    }
  },

  onKeyPress(e) {
    if(e.key === 'Enter') {
      let value = React.findDOMNode(this.refs.input).value;

      if(value.length > 0) {
        this.props.onLinkInput(value, this.props.node, this.props.range);
      } else {
        this.props.onLinkInput(null);
      }
      this.props.unMountPopOver();
    } else if (e.key === 'Esc') {
      this.props.unMountPopOver();
    }
  },

  getPosition(element) {
    var xPosition = 0;
    var yPosition = 0;
  
    while(element) {
        xPosition += (element.offsetLeft - element.scrollLeft + element.clientLeft);
        yPosition += (element.offsetTop - element.scrollTop + element.clientTop);
        element = element.offsetParent;
    }
    return { x: xPosition, y: yPosition };
  },

  render: function() {
    console.log('rendered', this.props.node.anchorNode.parentElement.offsetTop);
    let pos = this.props.node.anchorNode.parentElement;
    // GET POS BASED ON EDITOR POS.
    let styles = {
      top: pos.offsetTop - 57,
      left: pos.offsetLeft - 20
    };
    
    return (
      <div className="react-link-popover-wrapper" style={styles}>
        <div ref="popOver" className="react-link-popover">
          <input ref="input" className="link-popover-input" type="text" placeholder="Enter a link" onKeyPress={this.onKeyPress} />
        </div>
        <div className="link-popover-arrow"></div>
      </div>
    );
  }

});

export default PopOver;