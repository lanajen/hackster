import React, { Component, PropTypes } from 'react';
import { bindActionCreators } from 'redux';
import { connect } from 'react-redux';
import { Link } from 'react-router';

import Hero from '../components/Hero'

import * as AuthActions from '../actions/auth';

class Vendor extends Component {
  constructor(props) {
    super(props);
  }

  // React router and connect will complain if we move this up into the constructor.
  componentWillMount() {
    if(!this.props.auth.authorized) {
      this.props.actions.authorizeUser(true);
    }
  }

  render() {
    const { location, user, vendors } = this.props;

    let currentVendorIndex = 0;
    const currentVendor = vendors.filter((vendor, index) => {
      if(`/${vendor.user_name}` === location.pathname) {
        currentVendorIndex = index;
        return true;
      } else {
        return false;
      }
    })[0];

    const previousVendor = currentVendorIndex-1 > 0 ? vendors[currentVendorIndex-1] : vendors[vendors.length-1];
    const nextVendor = currentVendorIndex+1 < vendors.length-1 ? vendors[currentVendorIndex+1] : vendors[0];

    return (
      <div>
        <Hero user={user}/>
        <div id="vendor-details">
          <div className="details-wrapper">
            <div className="image-container">
              <div className="image-wrap">
                <img src={currentVendor.logo_url} className="logo" />
                <img src={currentVendor.board_image_url} className="board" />
              </div>
            </div>

            <div className="description-container">
              <div className="description">
                <strong>{currentVendor.board_name}</strong>
                <p>{currentVendor.board_description}</p>
                <div className="buttons">
                  <a href={currentVendor.website} className="button" target="_blank">Visit site</a>
                  <a href="javascript:void(0);" className="button">Share</a>
                </div>
              </div>
            </div>
          </div>

          <div className="vendor-links">
            {this._composeVendorLink(previousVendor, 'Previous')}
            {this._composeVendorLink(nextVendor, 'Up next')}
          </div>
        </div>
      </div>
    );
  }

  _composeVendorLink(vendor, info) {
    return (
      <Link to={`/${vendor.user_name}`} className="vendor-link-button">
        <div className="link-container">
          <div className="image">
            <img src={vendor.board_image_url} />
          </div>
          <div className="info">
            <p>{info}</p>
            <div className="vendor-name">{vendor.board_name}</div>
          </div>
        </div>
      </Link>
    );
  }
}

Vendor.PropTypes = {
 user: PropTypes.object.isRequired
}

function mapStateToProps(state) {
  return {
    auth: state.auth,
    user: state.user,
    vendors: state.vendors
  };
}

function mapDispatchToProps(dispatch) {
  return { actions: bindActionCreators(AuthActions, dispatch) };
}

export default connect(mapStateToProps, mapDispatchToProps)(Vendor);