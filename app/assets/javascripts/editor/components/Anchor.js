import React from 'react';
import { createRandomNumber } from '../../utils/Helpers';

const Anchor = React.createClass({

  onMouseOver(e) {
    // console.log(React.findDOMNode(this));
    console.log('hello');
  },

  createTemplate() {
    return '<a href=' + this.props.href + 'onmouseover=' + this.onMouseOver() + '>' + this.props.content + '</a>';
  },

  render() {
    return (
      <a key={createRandomNumber()} href={this.props.href} data-index-pos={this.props.indexPos} onMouseOver={this.onMouseOver}>{this.props.content}</a>
    );
  }
});

export default Anchor;