import React from 'react';
import rangy from 'rangy';
import cx from 'classnames';
import Utils from '../utils/DOMUtils';
import _ from 'lodash';

const ToolbarButton = React.createClass({

  propTypes: {
    classList: React.PropTypes.string,
    icon: React.PropTypes.string,
    onButtonClick: React.PropTypes.func
  },

  handleButtonClick(e) {
    e.preventDefault();
    e.stopPropagation();

    if(Utils.isAncestorOfContentEditable(rangy.getSelection().anchorNode)) {
      return;
    }

    let tagType = this.props.tagType || null;
    let valueArg = this.props.valueArg || null;

    this.props.onClick(tagType, valueArg);
  },

  render: function() {
    let icon = this.props.icon ? (<i className={this.props.icon}></i>) : null;
    let buttonClasses = this.props.classList;

    if(_.includes(this.props.activeButtons, this.props.tagType)) {
      buttonClasses = cx(buttonClasses, {['toolbar-btn-active']: true});
    } else {
      buttonClasses = cx(buttonClasses, {['toolbar-btn-active']: false});
    }

    return (
      <button className={buttonClasses} onClick={this.handleButtonClick}>
        {icon}
      </button>
    );
  }

});

export default ToolbarButton;