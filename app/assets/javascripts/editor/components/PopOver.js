import React from 'react';
import ReactDOM from 'react-dom';
import Utils from '../utils/DOMUtils';
import Validator from 'validator';
import _ from 'lodash';

const PopOver = React.createClass({

  componentWillMount() {
    if(window) {
      window.addEventListener('click', this.onBodyClick, false);

      this.debouncedScroll = _.debounce(this.handleScroll, 10);
      window.addEventListener('scroll', this.debouncedScroll, false);
    }
  },

  componentWillUnmount() {
    if(window) {
      window.removeEventListener('click', this.onBodyClick, false);
      window.removeEventListener('scroll', this.debouncedScroll, false);
    }
  },

  componentDidMount() {
    let input = ReactDOM.findDOMNode(this.refs.input);
    input.focus();
  },

  onBodyClick(e) {
    if( e.target === ReactDOM.findDOMNode(this.refs.input) || e.target === ReactDOM.findDOMNode(this.refs.input2) ) {
      return;
    } else if(e.target !== ReactDOM.findDOMNode(this)) {
      this.props.unMountPopOver();
    }
  },

  handleScroll() {
    this.props.unMountPopOver();
  },

  handleKeyPress(version, e) {
    if(e.key === 'Enter') {
      e.preventDefault();

      let value = ReactDOM.findDOMNode(this.refs.input).value;
      let text = ReactDOM.findDOMNode(this.refs.input2).value;

      /** Make sure the url protocol is added. */
      if(Validator.isURL(value)) {
        if(!Validator.isURL(value, { require_protocol: true })) {
          value = 'http://' + value;
        }
      } else {
        this.props.actions.toggleErrorMessenger(true, 'Not a valid url');
      }

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

  handleOnPopUpAnchorClick(url, e) {
    if(window) {
      e.preventDefault();
      window.open(url, '_blank');
    }
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
           ? { top: ((positions.y-100) - popOverProps.parentNode.offsetTop), left: ((positions.x-110) - popOverProps.parentNode.offsetLeft) }
           : { top: ((positions.y-100) - popOverProps.parentNode.offsetTop), left: ((positions.x-150) - popOverProps.parentNode.offsetLeft) };
    let textValue = popOverProps.text || '';
    let version;

    if(popOverProps.version === 'init' || popOverProps.version === 'change') {
      version = (<div className="link-popover-change-container">
                   <label>
                     <span>Text:</span>
                     <input ref="input2" className="link-popover-input" type="text" placeholder="Change text" defaultValue={textValue} onKeyPress={this.handleKeyPress.bind(this, popOverProps.version)} onKeyDown={this.handleKeyDown}/>
                   </label>
                   <label>
                     <span>Link:</span>
                     <input ref="input" className="link-popover-input" type="text" defaultValue={popOverProps.href} placeholder="Type a link" onKeyPress={this.handleKeyPress.bind(this, popOverProps.version)} onKeyDown={this.handleKeyDown}/>
                   </label>
                 </div>);
    } else {
      version = (<div ref="input" className="link-popover-default-container">
                   <a href={popOverProps.href} onClick={this.handleOnPopUpAnchorClick.bind(this, popOverProps.href)}>{popOverProps.href}</a>
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