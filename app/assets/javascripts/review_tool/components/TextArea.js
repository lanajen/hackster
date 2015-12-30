import React from 'react';

const TextArea = React.createClass({
  getInitialState: function() {
    return {
      isOpen: false,
      canCollapse: true
    }
  },

  handleInput: function(e) {
    this.setState({
      canCollapse: e.target.value === ''
    });
  },

  handleClick: function() {
    if (this.state.canCollapse) {
      this.setState({
        isOpen: !this.state.isOpen
      });
    }
  },

  render: function() {
    const { label, id } = this.props;

    let classes = ['form-group'];
    if (this.state.canCollapse) classes.push('expandable');
    if (!this.state.isOpen) classes.push('collapsed');
    classes = classes.join(' ');

    return (
      <div className={classes}>
        <label className="control-label unselectable" htmlFor={id} onClick={this.handleClick}>{label} {this.renderArrow()}</label>
        {this.renderTextArea()}
      </div>
    );
  },

  renderArrow: function() {
    if (!this.state.canCollapse) return null;

    let classes = this.state.isOpen ? ['fa-angle-up'] : ['fa-angle-down'];
    classes.push('fa');
    classes = classes.join(' ');

    return (
      <i className={classes}></i>
    );
  },

  renderTextArea: function() {
    let style = this.state.isOpen ? {} : {display: 'none'};

    return (
      <textarea rows="2" className="form-control" placeholder="Type feedback for this field" id={this.props.id} style={style} onKeyUp={this.handleInput} ref="textarea" />
    );
  }
});

export default TextArea;