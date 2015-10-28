import React, { Component } from 'react';

export default class TextArea extends Component {
  constructor(props) {
    super(props);
  }

  render() {
    return (
      <textarea placeholder="Hello"></textarea>
    );
  }
}