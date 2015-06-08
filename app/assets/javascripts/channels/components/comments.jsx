var CommentForm = React.createClass({
  getInitialState: function() {
    return {
      submitVisibility: 'hidden'
    };
  },

  focus: function(e){
    this.refs.body.getDOMNode().focus();
  },

  componentDidMount: function() {
    var body = $(this.refs.body.getDOMNode());

    body.on('keypress', this.handleKeypress);

    // auto adjust the height of the textarea
    body.on('keyup keydown', function() {
      var t = $(this);
      var h = t[0].scrollHeight - parseInt(t.css('padding-top')) - parseInt(t.css('padding-bottom'));
      t.height(21).height(h);  // where 21 is the minimum height of textarea (25 - 4 for padding)
    });

    body.tooltip({
      title: 'Press Enter to submit. Shift+Enter for a new line.',
      placement: 'top',
      trigger: 'focus',
      container: 'body'
    });
  },

  componentWillUnmount: function () {
    var body = $(this.refs.body.getDOMNode());
    body.off('focus blur keyup keypress keydown');
  },

  handleKeypress: function(e) {
    if (e.which == 13 && !e.shiftKey) {
      this.handleSubmit(e);
    }
  },

  handleSubmit: function(e) {
    e.preventDefault();

    var body = this.refs.body.getDOMNode().value.trim();
    if (!body)
      return;

    this.props.onCommentSubmit(body);
    this.refs.body.getDOMNode().value = '';
    $(this.refs.body.getDOMNode())
      .css('height', '')
      .tooltip('hide');
    this.getDOMNode().focus();
  },

  render: function() {
    var classes = ['comment-form'];

    return (
      <form ref='form' className={classes.join(' ')} onSubmit={this.handleSubmit}>
        <img className="img-rounded" src={user_data.avatar_url} />
        <div className="textarea-container">
          <textarea ref="body" placeholder="Type your comment" />
        </div>
      </form>
    );
  }
});

var LikesCount = React.createClass({
  render: function() {
    if (this.props.likes.count) {
      return (
        <span>
          <span className="separator">&bull;</span>
          <span>
            {this.props.likes.count}
            <i className='fa fa-thumbs-o-up' />
          </span>
        </span>
      );
    } else {
      return <div />
    }
  }
});

var Comment = React.createClass({
  mixins: [FluxMixin],

  handleDelete: function(e) {
    e.preventDefault();

    this.getFlux().actions.comments.remove(this.props.id);
  },

  handleLike: function(oldState) {
    this.getFlux().actions.comments.like(this.props.id, oldState);
  },

  render: function() {
    var idName = 'comment-' + this.props.id;
    var user = this.props.user;
    if (this.props.own) {
      var actions =
        <span>
          <a href='' onClick={this.handleDelete}>Delete</a>
          <span className="separator">&bull;</span>
        </span>;
    }
    var classes = ['comment'];
    if (this.props.deleted)
      classes.push('deleted');

              // <span className="separator">&bull;</span>
              // <a href=''>Mention</a>

    return (
      <div id={idName} className={classes.join(' ')}>
        <div className="media">
          <div className="media-left">
            <a href={user.url}>
              <img className="media-object img-rounded" src={user.avatar_url} />
            </a>
          </div>
          <div className="media-body">
            <p className="user"><a href={user.url}>{user.name}</a></p>
            <BodyContainer body={this.props.body} maxHeight='130'/>
            <div className="actions">
              <span className="time-created"><DateComponent timestamp={this.props.timestamp} /></span>
              <span className="separator">&bull;</span>
              {actions}
              <Like liked={this.props.liked} onButtonClick={this.handleLike} />
              <LikesCount likes={this.props.likes} />
            </div>
          </div>
        </div>
      </div>
    );
  }
});

var CommentList = React.createClass({
  render: function() {
    var commentNodes = this.props.comments.map(function(comment, index) {
      return (
        <Comment {...comment} key={index} />
      );
    });
    return (
      <div className="comment-list">
        {commentNodes}
      </div>
    );
  }
});

var CommentContainer = React.createClass({
  mixins: [FluxMixin],

  focusForm: function() {
    this.refs.commentForm.focus();
  },

  handleCommentSubmit: function(body, thoughtId) {
    this.getFlux().actions.comments.add({ body: body, thoughtId: this.props.thoughtId });
  },

  handleShowAll: function(e) {
    e.preventDefault();
    this.props.showAllComments(this.props.thoughtId);
  },

  render: function() {
    var more = '';
    if (this.props.moreCommentsCount) {
      more = (
        <div className="thought-comments-more">
          <a href="#" onClick={this.handleShowAll} >Show earlier comments ({this.props.moreCommentsCount})</a>
        </div>
      );
    }

    return (
      <div className='comment-container'>
        {more}
        <CommentList comments={this.props.comments} />
        <CommentForm ref='commentForm' onCommentSubmit={this.handleCommentSubmit} />
      </div>
    );
  }
});