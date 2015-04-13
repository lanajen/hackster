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

var LinkData = React.createClass({
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

var BodyContainer = React.createClass({
  componentDidMount: function() {
    var body = $(this.refs.bodyContainer.getDOMNode());
    var height = body.height();
    if (height > this.props.maxHeight) {
      body.data('orig-height', height);
      body.addClass('collapsed');
    }
  },
  componentDidUpdate: function(prevProps) {
    if (prevProps.body != this.props.body) {
      var body = $(this.refs.bodyContainer.getDOMNode());
      body.css('height', '');
      body.removeClass('collapsed');
      var height = body.height();
      if (height > this.props.maxHeight) {
        body.data('orig-height', height);
        body.addClass('collapsed');
      }
    }
  },

  expand: function(e) {
    e.preventDefault();

    var body = $(this.refs.bodyContainer.getDOMNode());
    var height = body.data('orig-height');
    body.animate({ height: height }, 150, function() {
      $(this).removeClass('collapsed');
    });
  },

  render: function() {
    return (
      <div className="body-container" ref='bodyContainer'>
        <div className="body" dangerouslySetInnerHTML={{__html: this.props.body}} />
        <a className="expand" onClick={this.expand}>See more...</a>
      </div>
    );
  }
});