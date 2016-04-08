// import React, { Component } from 'react';
// import { connect } from 'react-redux';


// export default function authenticateComponent (Component) {


//   class AuthenticatedComponent extends Component {

//     componentWillMount() {
//       this.checkAuth()
//     }

//     componentWillReceiveProps() {
//       this.checkAuth();
//     }

//     checkAuth() {
//       if (!this.props.isAuthenticated) {
//         console.log('THIS USER IS NOT AUTHENTICATED');
//       }
//     }

//     render() {
//       return (
//         <div>
//           {this.props.isAuthenticated === true
//             ? <Component/>
//             : null
//           }
//         </div>
//       )
//     }
//   }

//   const mapStateToProps = (state) => ({
//     token: state.auth.token,
//     isAuthenticated: state.auth.isAuthenticated
//   });

//   return connect(mapStateToProps)(AuthenticatedComponent);

// }
