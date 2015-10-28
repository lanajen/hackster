import React, { Component } from 'react';

export default class TextArea extends Component {
  constructor(props) {
    super(props);
  }

  render() {
    let placeholder = 'Share your thoughts! What do you like about this project? How could it be improved? Be respectful and constructive – most Hackster members create and share personal projects in their free time.';
    
    return (
      <textarea className="comments-textarea" placeholder={placeholder}></textarea>
    );
  }
}