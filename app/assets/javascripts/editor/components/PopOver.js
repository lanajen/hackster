import React from 'react';
import Utils from '../utils/DOMUtils';

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

    let { sel, range } = Utils.getSelectionData();
    range = this.props.popOverProps.range;
    sel.addRange(range);
  },

  onBodyClick(e) {
    if( e.target === React.findDOMNode(this.refs.input) || e.target === React.findDOMNode(this.refs.input2) ) {
      return;
    } else if(e.target !== React.findDOMNode(this)) {
      this.props.unMountPopOver();
    }
  },

  handleKeyPress(version, e) {
    if(e.key === 'Enter') {
      let value = React.findDOMNode(this.refs.input).value;
      let text = React.findDOMNode(this.refs.input2).value;

      if(value.length > 0) {
        if(version === 'init') {
          this.props.onLinkInput(value, text, this.props.popOverProps.range);
        } else {
          this.props.onInputChange(value, text, this.props.popOverProps.node, this.props.popOverProps.range);
        }
      } else {
        this.props.onLinkInput(null);
      }
      this.props.unMountPopOver();
    }
  },

  handleKeyDown(e) {
    if(e.key === 'Escape') {
      this.props.unMountPopOver();
    }
  },

  handleAnchorChange() {
    let props = this.props.popOverProps;
    this.props.onVersionChange(props);
  },

  handleRemoveAnchorTag() {
    this.props.removeAnchorTag();
  },

  getPositions() {
    let p = Utils.getSelectionCoords();
    let positions = {
      x: p.x,
      y: p.y
    }
    return positions;
  },

  render: function() {
    let popOverProps = this.props.popOverProps;
    let positions = this.getPositions();
    let styles = popOverProps.version === 'init' || popOverProps.version === 'change' 
           ? { top: ((positions.y-80) - popOverProps.parentNode.offsetTop), left: ((positions.x-120) - popOverProps.parentNode.offsetLeft) }
           : { top: ((positions.y-80) - popOverProps.parentNode.offsetTop), left: ((positions.x-150) - popOverProps.parentNode.offsetLeft) };
    let textValue = popOverProps.text || '';
    let version;

    if(popOverProps.version === 'init') {
      version = (<div className="link-popover-init-container">
                   <input ref="input" className="link-popover-input" type="text" placeholder="Type a link" onKeyPress={this.handleKeyPress.bind(this, 'init')} onKeyDown={this.handleKeyDown}/>
                   <input ref="input2" className="link-popover-input" type="text" placeholder="Change text" defaultValue={textValue} onKeyPress={this.handleKeyPress.bind(this, 'init')} onKeyDown={this.handleKeyDown}/>
                 </div>);
    } else if(popOverProps.version === 'change') {
      version = (<div className="link-popover-change-container">
                   <input ref="input" className="link-popover-input" type="text" placeholder="Type a link" defaultValue={popOverProps.href} onKeyPress={this.handleKeyPress.bind(this, 'change')} onKeyDown={this.handleKeyDown}/>
                   <input ref="input2" className="link-popover-input" type="text" placeholder="Change text" defaultValue={textValue} onKeyPress={this.handleKeyPress.bind(this, 'change')} onKeyDown={this.handleKeyDown}/>
                 </div>);
    } else {
      version = (<div ref="input" className="link-popover-default-container">
                   <a href={popOverProps.href}>{popOverProps.href}</a>
                   <a href="javascript:void(0);" onClick={this.handleAnchorChange}>Change</a>
                   <a href="javascript:void(0);" onClick={this.handleRemoveAnchorTag}>Remove</a>
                 </div>);
    }

    return (
      <div className="react-link-popover-wrapper" style={styles}>
        <div ref="popOver" className="react-link-popover">
          {version}
        </div>
        <div className="link-popover-arrow"></div>
      </div>
    );
  }

});

export default PopOver;