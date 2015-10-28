import React, { Component, PropTypes } from 'react';
import CommentForm from './CommentForm';

export default class Comments extends Component {
  constructor(props) {
    super(props);
  }

  render() {
    let initialForm = this.props.userSignedIn 
                    ? (<CommentForm />) 
                    : (null);
    return (
      <div>
        {initialForm}
        <div>Comments...</div>
      </div>
    );
  }
}

Comments.PropTypes = {
  userSignedIn: PropTypes.number
};