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

  getPositions(element) {
    let b = element.getBoundingClientRect();
    let positions = {
      x: b.left,
      y: b.top,
      x2: b.right,
      y2: b.bottom,
      w: b.right - b.left,
      h: b.bottom - b.top
    }
    return positions;
  },

  render: function() {
    let popOverProps = this.props.popOverProps;
    let positions = this.getPositions(popOverProps.node.parentNode);
    let CP = popOverProps.range.startOffset;
    let styles = {
      top: popOverProps.version === 'init' || popOverProps.version === 'change' ? positions.y - 70 : positions.y - 50,
      left: (positions.x - 50) + (CP * 6)
    };

    let textValue = popOverProps.text || '';
    let version;

    if(popOverProps.version === 'init') {
      version = (<div className="link-popover-input-container">
                   <input ref="input" className="link-popover-input" type="text" placeholder="Type a link" onKeyPress={this.handleKeyPress.bind(this, 'init')} onKeyDown={this.handleKeyDown}/>
                   <input ref="input2" className="link-popover-input" type="text" placeholder="Change text" defaultValue={textValue} onKeyPress={this.handleKeyPress.bind(this, 'init')} onKeyDown={this.handleKeyDown}/>
                 </div>);
    } else if(popOverProps.version === 'change') {
      version = (<div className="link-popover-input-container">
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