var ChannelHeader = React.createClass({
  render: function() {
    return (
      <div className="channel-header">
        <h1>{this.props.title}</h1>
      </div>
    );
  }
});

var ChannelContainer = React.createClass({
  mixins: [FluxMixin, StoreWatchMixin("thought")],

  contextTypes: {
    router: React.PropTypes.func
  },

  getStateFromFlux: function() {
    var params = this.context.router.getCurrentParams();
    var data = {};
    if (params.hashtag)
      data['hashtag'] = params.hashtag;

    return this.getFlux().store("thought").getThoughts(data);
  },

  componentWillReceiveProps: function(nextProps) {
    this.setState(this.getStateFromFlux());
  },

  handleThoughtSubmit: function(body) {
    this.getFlux().actions.thoughts.add(body);
  },

  handleLoadMoreThoughts: function(e) {
    e.preventDefault();
    this.setState({ loading: true });
    var data = { page: this.state.nextPage };
    var params = this.context.router.getCurrentParams();
    if (params.hashtag)
      data['hashtag'] = params.hashtag;
    this.getFlux().actions.thoughts.loadMore(data);
  },

  componentDidMount: function() {
    window.addEventListener('scroll', this.handleScroll);
  },

  componentWillUnmount: function() {
    window.removeEventListener('scroll', this.handleScroll);
  },

  handleScroll: function(e) {
    if ($('.load-more').length && $(window).scrollTop() > $(document).height() - $(window).height() - 1000) {
      this.handleLoadMoreThoughts(e);
    }
  },

  render: function() {
    var params = this.context.router.getCurrentParams();

    var title = 'Public feed';
    if (params.hashtag)
      title = '#' + params.hashtag + ' channel';

    var loadMoreButton = '';
    if (this.state.loading) {
      loadMoreButton = (
        <div className="text-center">
          <i className="fa fa-spin fa-spinner fa-3x"></i>
        </div>
      );
    } else if (this.state.nextPage) {
      loadMoreButton = (
        <a href='#' className="btn btn-block btn-default load-more" onClick={this.handleLoadMoreThoughts}>Load more</a>
      );
    }

    return (
      <div className="channel-container">
        <ChannelHeader title={title} />
        <ThoughtForm onThoughtSubmit={this.handleThoughtSubmit} />
        <ThoughtList thoughts={this.state.thoughts} />
        {loadMoreButton}
      </div>
    );
  }
});