import React, { Component, PropTypes } from 'react';
import { bindActionCreators } from 'redux';
import { connect } from 'react-redux';
import * as CommentsActions from '../actions/comments';
import Comments from '../components/Comments';
import CommentForm from '../components/CommentForm';

class CommentsContainer extends Component {

  constructor(props) {
    super(props);
  }

  render() {
    let initialForm = this.props.userSignedIn 
                    ? (<CommentForm />) 
                    : (null);
    return (
      <div className="r-comments">
        {initialForm}
        <Comments { ...this.props } />
      </div>
    );
  }
}

CommentsContainer.PropTypes = {
  userSignedIn: PropTypes.number
};

function mapStateToProps(state) {
  return {
    comments: state.comments
  };
}

function mapDispatchToProps(dispatch) {
  return { actions: bindActionCreators(Object.assign({}, CommentsActions), dispatch) };
}

export default connect(mapStateToProps, mapDispatchToProps)(CommentsContainer);