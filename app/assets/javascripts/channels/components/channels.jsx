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

    return {
      thoughts: this.getFlux().store("thought").getThoughts(data)
    };
  },

  // componentDidMount: function() {
  //   this.getFlux().actions.thoughts.load();
  // },

  componentWillReceiveProps: function(nextProps) {
    this.setState(this.getStateFromFlux());
  },

  handleThoughtSubmit: function(body) {
    this.getFlux().actions.thoughts.add(body);
  },

  render: function() {
    var params = this.context.router.getCurrentParams();

    var title = 'Public feed';
    if (params.hashtag)
      title = '#' + params.hashtag + ' channel';

    return (
      <div className="channel-container">
        <ChannelHeader title={title} />
        <ThoughtForm onThoughtSubmit={this.handleThoughtSubmit} />
        <ThoughtList thoughts={this.state.thoughts} />
      </div>
    );
  }
});