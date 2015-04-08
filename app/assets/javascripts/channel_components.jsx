// utils
function arrayToSentence(array){
  var output = '';
  array.forEach(function(val, i){
    if ((i + 2) < array.length) {
      output += val + ', ';
    } else if ((i + 2) == array.length) {
      output += val + ' and ';
    } else {
      output += val;
    }
  });
  return output;
}

var FluxMixin = Fluxxor.FluxMixin(React),
    StoreWatchMixin = Fluxxor.StoreWatchMixin;

var ChannelHeader = React.createClass({
  render: function() {
    return (
      <div className="channel-header">
        <h1>Public feed</h1>
      </div>
    );
  }
});

var DateComponent = React.createClass({
  componentDidMount: function() {
    this.refresh();
  },

  refresh: function() {
    if (!this.isMounted())
      return;

    var period = 10000;

    var now = Date.now() / 1000;
    var seconds = Math.round(Math.abs(this.props.timestamp - now));

    // refresh periods match momentjs
    if (seconds < 90) {
      period = 30 * 1000;  // 30 secs
    } else if (seconds < 45 * 60) {  // 45 mins
      period = 60 * 1000;  // 60 secs
    } else if (seconds < 90 * 60) {  // 90 mins
      period = 30 * 60 * 1000;  // 30 mins
    } else if (seconds < 22 * 60 * 60) {  // 22 hours
      period = 60 * 60 * 1000;  // 1 hour
    } else if (seconds < 25 * 60 * 60 * 24) {  // 25 days
      period = 24 * 60 * 60 * 1000;  // 1 day
    } else {
      period = 0;
    }

    if (!period)
      return;

    var _ = this;
    var timer = window.setTimeout(function(){
      _.forceUpdate();
      _.refresh();
    }, period);

    this.setState({ timer: timer });  // so we can clear it when unmounting
  },

  componentWillUnmount: function() {
    if (this.state && this.state.timer)
      window.clearTimeout(this.state.timer);
  },


  render: function(){
    var date = moment.unix(this.props.timestamp).fromNow();

    return (
      <span>{date}</span>
    );
  }
});

var ThoughtForm = React.createClass({
  handleSubmit: function(e){
    e.preventDefault();

    this.refs.submit.getDOMNode().blur();

    var body = this.refs.body.getDOMNode().value.trim();
    if (!body) {
      return;
    }
    this.props.onThoughtSubmit(body);
    this.refs.body.getDOMNode().value = '';
  },

  render: function() {
    return (
      <form className="thought-form" onSubmit={this.handleSubmit}>
        <div className="textarea-container">
          <textarea ref="body" placeholder="Share something interesting or ask a question." />
        </div>
        <div className="submit-container">
          <input ref="submit" className="btn btn-primary" type="submit" value="Post" />
        </div>
      </form>
    );
  }
});

var Link = React.createClass({
  render: function() {
    var data = this.props.data;
    if (data.image_link)
      var img = <img className='media-object' src={data.image_link} />

    if (this.props.link) {
      return (
        <a className='thought-link' href={this.props.link} target='_blank'>
          <div className='media'>
            <div className='media-body'>
              <div className='thought-link-inner'>
                <h5 className='media-heading'>{data.title}</h5>
                <p className="description">{data.description}</p>
                <p className="website">{data.website_name}</p>
              </div>
            </div>
            <div className='media-right'>
              {img}
            </div>
          </div>
        </a>
      );
    } else {
      return <div />
    }
  }
});

var Like = React.createClass({
  handleClick: function(e) {
    e.preventDefault();

    var oldState = this.props.liked;
    this.props.onButtonClick(oldState);
  },


  render: function() {
    var text = this.props.liked ? 'Liked' : 'Like';

    return (
      <a href='' onClick={this.handleClick}>{text}</a>
    );
  }
});

var Thought = React.createClass({
  mixins: [FluxMixin],

  handleComment: function(e) {
    e.preventDefault();

    this.props.onCommentClick();
  },

  handleDelete: function(e) {
    e.preventDefault();

    this.getFlux().actions.thoughts.remove(this.props.id);
  },

  handleLike: function(oldState) {
    this.getFlux().actions.thoughts.like(this.props.id, oldState);
  },

  render: function() {
    var user = this.props.user;
    if (this.props.own) {
      var actions =
        <span>
          <a href='' onClick={this.handleDelete}>Delete</a>
          <span className="separator">&bull;</span>
        </span>;
    }

    return (
      <div className="thought">
        <div className="media">
          <div className="media-left">
            <a href={user.url}>
              <img className="media-object img-rounded" src={user.avatar_url} />
            </a>
          </div>
          <div className="media-body">
            <h4 className="user media-heading"><a href={user.url}>{user.name}</a></h4>
            <p className="time-created"><DateComponent timestamp={this.props.timestamp} /></p>
          </div>
        </div>
        <div className="body" dangerouslySetInnerHTML={{__html: this.props.body}} />
        <Link link={this.props.link} data={this.props.link_data} />
        <div className="actions">
          {actions}
          <Like liked={this.props.liked} onButtonClick={this.handleLike} />
          <span className="separator">&bull;</span>
          <a href='' onClick={this.handleComment}>Comment</a>
          {/*<span className="separator">&bull;</span>
                    <a href=''>Share</a>*/}
        </div>
      </div>
    );
  }
});

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
    body.on('focus blur keyup', this.updateSubmit);
  },

  handleSubmit: function(e){
    e.preventDefault();

    var body = this.refs.body.getDOMNode().value.trim();
    if (!body) {
      return;
    }
    this.props.onCommentSubmit(body);
    this.refs.body.getDOMNode().value = '';
    this.getDOMNode().focus();
    this.updateSubmit(e);
  },

  updateSubmit: function(e) {
    var body = this.refs.body.getDOMNode();
    if (body.value.length) {
      this.setState({ submitVisibility: 'ready' });
    } else {
      if (e.type == 'focus' || $(body).is(':focus')) {
        this.setState({ submitVisibility: 'disabled' });
      } else {
        this.setState({ submitVisibility: 'hidden' });
      }
    }
  },

  render: function() {
    var classes = ['comment-form'];
    classes.push('submit-' + this.state.submitVisibility);

    return (
      <form className={classes.join(' ')} onSubmit={this.handleSubmit}>
        <img className="img-rounded" src={user_data.avatar_url} />
        <div className="textarea-container">
          <textarea ref="body" placeholder="Type your comment" />
          <input ref="submit" disabled={this.state.submitVisibility == 'disabled'} className="btn btn-primary btn-sm" type="submit" value="Post" />
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
            <div className="body" dangerouslySetInnerHTML={{__html: this.props.body}} />
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

  render: function() {
    return (
      <div className='comment-container'>
        <CommentList comments={this.props.comments} />
        <CommentForm ref='commentForm' onCommentSubmit={this.handleCommentSubmit} />
      </div>
    );
  }
});

var ThoughtLikes = React.createClass({
  render: function() {
    var likes = this.props.likes;
    var liked = this.props.liked;
    var nameList = [];
    if (liked)
      nameList.push('You');
    likes.likers.map(function(liker){
      nameList.push("<a href='" + liker.url + "'>" + liker.name + "</a>");
    });
    var others = 0;
    if (liked) {
      others = likes.count - 3;
    } else {
      others = likes.count - 2;
    }
    if (others > 0) {
      var othersAdj = (others == 1) ? 'other' : 'others';
      nameList.push(others + ' ' + othersAdj);
    }
    var verb = (nameList.length == 1 && !liked) ? 'likes' : 'like';
    var content = arrayToSentence(nameList) + ' ' + verb + ' this.';

    if (likes.count) {
      return (
        <div className='likes-container' dangerouslySetInnerHTML={{__html: content}} />
      );
    } else {
      return <div />;
    }
  }
});

var ThoughtContainer = React.createClass({
  handleComment: function() {
    window.thoughtContainer = this;
    this.refs.commentContainer.focusForm();
  },

  render: function() {
    var thought = this.props.thought;

    var classes = ['thought-container'];
    if (thought.deleted)
      classes.push('deleted');

    return (
      <div className={classes.join(' ')}>
        <Thought {...thought} onCommentClick={this.handleComment} />
        <ThoughtLikes likes={thought.likes} liked={thought.liked} />
        <CommentContainer ref='commentContainer' thoughtId={thought.id} comments={thought.comments} />
      </div>
    );
  }
});

var ThoughtList = React.createClass({
  render: function() {
    var thoughtNodes = this.props.data.map(function(thought, index) {
      return (
        <ThoughtContainer thought={thought} key={index} />
      );
    });
    return (
      <div className="thought-list">
        {thoughtNodes}
      </div>
    );
  }
});

var ChannelContainer = React.createClass({
  mixins: [FluxMixin, StoreWatchMixin("thought")],

  getStateFromFlux: function() {
    return {
      thoughts: this.getFlux().store("thought").getThoughts()
    };
  },

  componentDidMount: function() {
    this.getFlux().actions.thoughts.load();
  },

  handleThoughtSubmit: function(body) {
    this.getFlux().actions.thoughts.add(body);
  },

  render: function() {
    return (
      <div className="channel-container">
        <ChannelHeader />
        <ThoughtForm onThoughtSubmit={this.handleThoughtSubmit} />
        <ThoughtList data={this.state.thoughts} />
      </div>
    );
  }
});

var channelComponent = React.render(
  <ChannelContainer flux={flux} />,
  document.getElementById('react-container')
);