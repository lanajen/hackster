var EmptyView = React.createClass({
  render: function() {
    return <RouteHandler {...this.props} />;
  }
});

var NotFound = React.createClass({
  render: function() {
    return (
      <div>
        Nothing to see here.
      </div>
    );
  }
});