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
    React.findDOMNode(this.refs.input).focus();
  },

  onBodyClick(e) {
    if(e.target !== React.findDOMNode(this)) {
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
    let pos = this.getPosition(this.props.node.anchorNode.parentElement);
    let styles = {
      position: 'absolute'
    };
    
    return (
      <div style={styles}>
        <input ref="input" type="text" placeholder="Enter a link" onKeyPress={this.onKeyPress} />
      </div>
    );
  }

});

export default PopOver;