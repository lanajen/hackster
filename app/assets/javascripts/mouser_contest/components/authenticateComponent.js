import React, { Component } from 'react';
import { connect } from 'connect';


export function authenticateComponent(Component) {


  class AuthenticatedComponent extends Component {

    componentWillMount() {
      //check authentication each time an authenticated route is hit by react- router
      this.checkAuth()
    }

    componentWillRecieveProps() {
      //check auth again
      this.checkAuth();
    }


    render() {
      return (
        <div>
          {

          }
        </div>

      )
    }

  }
//map redux state to props
//this will include all of the current user's information (really just the token)
const mapStateToProps = (state) => ({
  token: state.auth.token
});

connect(mapStateToProps)(AuthenticatedComponent);

}
