//= require_self
//= require react_ujs

global.React = require('react');
global.FollowButton = require('./follow_button/app');
global.Tester = React.createClass({
  render() {
    console.log('TESTER RENDERED!');
    return (
      <div>HELLO</div>
    );
  }
});
