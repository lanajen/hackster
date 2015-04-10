var channelConstants = {
  COMMENT: {
    ADD: "COMMENT:ADD",
    LIKE: "COMMENT:LIKE",
    REMOVE: "COMMENT:REMOVE",
  },
  THOUGHT: {
    ADD: "THOUGHT:ADD",
    LIKE: "THOUGHT:LIKE",
    LOAD: "THOUGHT:LOAD",
    REMOVE: "THOUGHT:REMOVE"
  },
  ROUTE: {
    TRANSITION: "ROUTE:TRANSITION"
  }
};

var methods = {
  comments: {
    add: function(payload) {
      this.dispatch(channelConstants.COMMENT.ADD, {
        body: payload.body,
        thoughtId: payload.thoughtId
      });
    },

    like: function(id, oldState) {
      this.dispatch(channelConstants.COMMENT.LIKE, {
        id: id,
        oldState: oldState
      });
    },

    remove: function(id) {
      this.dispatch(channelConstants.COMMENT.REMOVE, id);
    }
  },

  thoughts: {
    add: function(body) {
      this.dispatch(channelConstants.THOUGHT.ADD, {
        body: body
      });
    },

    like: function(id, oldState) {
      this.dispatch(channelConstants.THOUGHT.LIKE, {
        id: id,
        oldState: oldState
      });
    },

    load: function(comments) {
      this.dispatch(channelConstants.THOUGHT.LOAD, comments);
    },

    remove: function(id) {
      this.dispatch(channelConstants.THOUGHT.REMOVE, id);
    }
  },

  routes: {
    transition: function(path, params) {
      this.dispatch(c.ROUTE.TRANSITION, {path: path, params: params});
    }
  }
};

var actions = {
  methods: methods,
  constants: channelConstants
};

var NOT_FOUND_TOKEN = {};

var CommentStore = Fluxxor.createStore({
  initialize: function() {
    this.commentId = 0;
    this.comments = {};

    this.bindActions(
      actions.constants.COMMENT.ADD, this.handleAddComment,
      actions.constants.COMMENT.LIKE, this.handleLikeComment,
      actions.constants.COMMENT.REMOVE, this.handleRemoveComment
    );
  },

  getComment: function(id) {
    return this.comments[id] || NOT_FOUND_TOKEN;
  },

  setComments: function(comments) {
    comments = comments || {};
    var hash = {};
    for (var i = 0; i < comments.length; ++i) {
      var comment = comments[i];
      comment.user = this.flux.store('user').getUser(comment.user_id);
      hash[comment.id] = comment;
    }

    this.comments = hash;
    this.emit('change');
  },

  prepareNewComment: function(body, thoughtId) {
    comment = {
      body: body,
      timestamp: Date.now()/1000,
      liked: false,
      own: true,
      deleted: false,
      commentable_id: thoughtId,
      likes: {
        count: 0,
        likers: []
      }
    };
    comment.id = 'tmpCommentId' + this.commentId;  // arbitrary so it gets at the top
    comment.user = user_data;  // has to be defined in the DOM
    return comment;
  },

  handleAddComment: function(payload) {
    var body = payload.body;
    var thoughtId = payload.thoughtId;
    var comment = this.prepareNewComment(body, thoughtId);
    var tmpId = comment.id;
    this.comments[tmpId] = comment;
    this.flux.store('thought').addCommentId(comment.commentable_id, tmpId);
    this.flux.store('thought').emit('change');

    $.ajax({
      url: '/api/v1/comments',
      dataType: 'json',
      type: 'POST',
      data: { thought_id: thoughtId, comment: { raw_body: body } },
      success: function(data) {
        var newComment = this.comments[tmpId];
        newComment.id = data.comment.id;
        newComment.body = data.comment.body;
        this.comments[newComment.id] = newComment;
        this.flux.store('thought').addCommentId(comment.commentable_id, newComment.id);
        this.flux.store('thought').removeCommentId(comment.commentable_id, tmpId);
        delete this.comments[tmpId];
      }.bind(this),
      error: function(xhr, status, err) {
        console.error('cant add', status, err.toString());
        this.flux.store('thought').removeCommentId(comment.commentable_id, tmpId);
        delete this.comments[comment.id]
      }.bind(this),
      complete: function() {
        this.flux.store('thought').emit('change');
      }.bind(this)
    });
  },

  handleLikeComment: function(payload) {
    var oldState = payload.oldState;
    var action = oldState ? 'DELETE' : 'POST';
    var comment = this.comments[payload.id];
    var count = oldState ? -1 : 1;

    comment.liked = !oldState;
    comment.likes.count += count;
    this.flux.store('thought').emit('change');

    $.ajax({
      url: '/api/v1/likes',
      dataType: 'json',
      type: action,
      data: { comment_id: comment.id },
      success: function(data) {
        comment.liked = data.liked;
      }.bind(this),
      error: function(xhr, status, err) {
        comment.liked = oldState;
        comment.likes.count -= count;
      }.bind(this),
      complete: function() {
        this.flux.store('thought').emit('change');
      }.bind(this)
    });
  },

  handleRemoveComment: function(id) {
    var comment = this.comments[id];
    comment.deleted = true;
    this.flux.store('thought').emit('change');

    $.ajax({
      url: '/api/v1/comments/' + id,
      dataType: 'json',
      type: 'DELETE',
      success: function(data) {
        this.flux.store('thought').removeCommentId(comment.commentable_id, id);
        delete this.comments[id];
      }.bind(this),
      error: function(xhr, status, err) {
        comment.deleted = false;
        console.log('error deleting', status, err.toString());
      }.bind(this),
      complete: function() {
        this.flux.store('thought').emit('change');
      }.bind(this)
    });
  }
});

var ThoughtStore = Fluxxor.createStore({
  initialize: function() {
    this.thoughtId = 0;
    this.thoughts = {};
    this.currentData = {};

    this.bindActions(
      actions.constants.THOUGHT.ADD, this.handleAddThought,
      actions.constants.THOUGHT.LIKE, this.handleLikeThought,
      actions.constants.THOUGHT.LOAD, this.handleLoadThoughts,
      actions.constants.THOUGHT.REMOVE, this.handleRemoveThought
    );
  },

  getThoughts: function(data) {
    data = data || {};

    if (data['hashtag'] != this.currentData['hashtag']) {
      this.handleLoadThoughts(data);
      this.currentData = data;
    }

    return Object.keys(this.thoughts).reverse().map(function(key) {
      var t = this.thoughts[key];
      return this.populateThought(t);
    }.bind(this));
  },

  getThought: function(id) {
    var thought = this.thoughts[id];
    if (thought) {
      return this.populateThought(thought);
    }

    this.loadThought(id);

    return NOT_FOUND_TOKEN;
  },

  populateThought: function(thought) {
    thought.comments = [];
    thought.comment_ids.forEach(function(id){
      var comment = this.flux.store('comment').getComment(id);
      if (comment)
        thought.comments.push(comment);
    });
    thought.user = this.flux.store('user').getUser(thought.user_id);
    return thought;
  },

  setThoughts: function(thoughts) {
    var hash = {};
    for (var i = 0; i < thoughts.length; ++i) {
      var thought = thoughts[i];
      hash[thought.id] = thought;
    }

    this.thoughts = hash;
    this.emit('change');
  },

  prepareNewThought: function(body) {
    thought = {
      body: body,
      timestamp: Date.now()/1000,
      liked: false,
      own: true,
      deleted: false,
      comment_ids: [],
      likes: {
        count: 0,
        likers: []
      },
      link_data: {},
      user_id: user_data.id  // has to be defined in the DOM
    };
    thought.id = Math.max.apply(Math, Object.keys(this.thoughts)) + 1000;  // arbitrary so it gets at the top
    thought.user = user_data;
    return thought;
  },

  loadThought: function(id) {
    $.ajax({
      url: '/api/v1/thoughts/' + id,
      dataType: 'json',
      type: 'GET',
      success: function(data) {
        this.flux.store('user').setUsers(data.users);
        this.flux.store('comment').setComments(data.comments);
        this.thoughts[data.thought.id] = data.thought;
        // this.setThoughts({ thoughts: [data.thought] });
        this.emit("change");
      }.bind(this),
      error: function(xhr, status, err) {
        console.error('cant load', status, err.toString());
      }.bind(this),
      complete: function() {
      }.bind(this)
    });
  },

  handleLoadThoughts: function(data) {
    $.ajax({
      url: 'api/v1/thoughts',
      data: data,
      dataType: 'json',
      type: 'GET',
      success: function(data) {
        this.flux.store('user').setUsers(data.users);
        this.flux.store('comment').setComments(data.comments);
        this.setThoughts(data.thoughts);
      }.bind(this),
      error: function(xhr, status, err) {
        console.error('cant load', status, err.toString());
      }.bind(this),
      complete: function() {
      }.bind(this)
    });
  },

  addCommentId: function(id, commentId) {
    var thought = this.thoughts[id];
    thought.comment_ids.push(commentId);
  },

  removeCommentId: function(id, commentId) {
    var thought = this.thoughts[id];
    var i = thought.comment_ids.indexOf(commentId);
    thought.comment_ids.splice(i, 1);
  },

  handleAddThought: function(payload) {
    var body = payload.body;
    var thought = this.prepareNewThought(body);
    var tmpId = thought.id;
    this.thoughts[tmpId] = thought;
    this.emit('change');

    $.ajax({
      url: '/api/v1/thoughts',
      dataType: 'json',
      type: 'POST',
      data: { thought: { raw_body: body } },
      success: function(data) {
        this.thoughts[data.thought.id] = data.thought;
        delete this.thoughts[tmpId];
      }.bind(this),
      error: function(xhr, status, err) {
        console.error('cant add', status, err.toString());
        delete this.thoughts[thought.id]
      }.bind(this),
      complete: function() {
        this.emit("change");
      }.bind(this)
    });
  },

  handleLikeThought: function(payload) {
    var oldState = payload.oldState;
    var action = oldState ? 'DELETE' : 'POST';
    var count = oldState ? -1 : 1;
    var thought = this.thoughts[payload.id];

    thought.liked = !oldState;
    thought.likes.count += count;
    this.emit('change');

    $.ajax({
      url: '/api/v1/likes',
      dataType: 'json',
      type: action,
      data: { thought_id: thought.id },
      success: function(data) {
        thought.liked = data.liked;
      }.bind(this),
      error: function(xhr, status, err) {
        thought.liked = oldState;
        thought.likes.count -= count;
      }.bind(this),
      complete: function() {
        this.emit("change");
      }.bind(this)
    });
  },

  handleRemoveThought: function(id) {
    var thought = this.thoughts[id];
    thought.deleted = true;
    this.emit('change');

    $.ajax({
      url: '/api/v1/thoughts/' + id,
      dataType: 'json',
      type: 'DELETE',
      success: function(data) {
        delete this.thoughts[id];
      }.bind(this),
      error: function(xhr, status, err) {
        thought.deleted = false;
        console.log('error deleting', status, err.toString());
      }.bind(this),
      complete: function() {
        this.emit("change");
      }.bind(this)
    });
  }
});

var UserStore = Fluxxor.createStore({
  initialize: function() {
    this.users = {};
  },

  getUser: function(id) {
    return this.users[id] || NOT_FOUND_TOKEN;
  },

  setUsers: function(users) {
    users = users || {};
    var hash = {};
    for (var i = 0; i < users.length; ++i) {
      var user = users[i];
      hash[user.id] = user;
    }
    hash[user_data.id] = user_data;

    this.users = hash;
    this.emit('change');
  },
});

var RouteStore = Fluxxor.createStore({
  initialize: function(options) {
    this.router = options.router;

    this.bindActions(
      actions.constants.ROUTE.TRANSITION, this.handleRouteTransition
    );
  },

  handleRouteTransition: function(payload) {
    var path = payload.path,
        params = payload.params;

    this.router.transitionTo(path, params);
  }
});

ThoughtStore.NOT_FOUND_TOKEN = NOT_FOUND_TOKEN;