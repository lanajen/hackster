import React from 'react';
import cx from 'classnames';

const ToolbarButton = React.createClass({

  propTypes: {
    classList: React.PropTypes.string,
    icon: React.PropTypes.string,
    onButtonClick: React.PropTypes.func
  },

  onButtonClick(e) {
    e.preventDefault();
    e.stopPropagation();

    let tagType = this.props.tagType || null;
    let valueArg = this.props.valueArg || null;

    this.props.onClick(tagType, valueArg);
  },

  render: function() {
    let buttonClasses = cx('btn', this.props.classList);
    let icon = this.props.icon ? (<i className={this.props.icon}></i>) : null;

    return (
      <button className={buttonClasses} onClick={this.onButtonClick}>
        {icon}
      </button>
    );
  }

});

export default ToolbarButton;