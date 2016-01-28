import React, { Component, PropTypes } from 'react';

export default class Thumbnail extends Component {
  constructor(props) {
    super(props);

    this.handleChangeLinkClick = this.handleChangeLinkClick.bind(this);
  }

  handleChangeLinkClick(e) {
    e.preventDefault();
    this.props.actions.changeSelection(this.props.name.toLowerCase());
  }

  render() {
    const { name } = this.props;
    let views = {
      'Course': this._createCourseThumb(this.props),
      'Generic': this._createGenericThumb(this.props),
      'Promotion': this._createPromotionThumb(this.props),
      'University': this._createUniversityThumb(this.props)
    };

    let view = views[name] ? views[name] : views['Generic'];

    return view();
  }

  _createUniversityThumb(props) {
    const { imageData, avatar_url, city, country, full_name } = props.uniqueStore;
    return function() {
      return (
        <div className="course-wizard-thumbnail">
          <img src={avatar_url ? avatar_url : imageData ? imageData.dataUrl : ''} />
          <div className="thumbnail-details">
            <a href="#">{full_name}</a>
            <div>
              <i className="fa fa-map-marker" />
              <span>{`${city}, ${country}`}</span>
            </div>
          </div>
          <div className="change-link-wrapper">
            <a href="javascript:void(0);" onClick={this.handleChangeLinkClick}>Change</a>
          </div>
        </div>
      );
    }.bind(this);
  }

  _createCourseThumb(props) {
    const { imageData, full_name, course_number, mini_resume, cover_image_url } = props.uniqueStore;
    return function() {
      return (
        <div className="course-wizard-thumbnail">
          <img src={cover_image_url ? cover_image_url: imageData ? imageData.dataUrl : ''} />
          <div className="thumbnail-details">
            <a href="#">{full_name}</a>
            <div>{`Course# ${course_number || ''}`}</div>
            <div>{`Pitch: ${mini_resume || ''}`}</div>
          </div>
          <div className="change-link-wrapper">
            <a href="javascript:void(0);" onClick={this.handleChangeLinkClick}>Change</a>
          </div>
        </div>
      );
    }.bind(this);
  }

  _createPromotionThumb(props) {
    const { full_name } = props.uniqueStore;
    return function() {
      return (
        <div className="course-wizard-thumbnail">
          <h2>{full_name}</h2>
          <div className="change-link-wrapper">
            <a href="javascript:void(0);" onClick={this.handleChangeLinkClick}>Change</a>
          </div>
        </div>
      );
    }.bind(this);
  }

  _createGenericThumb(props) {
    return function() {
      return (
        <div className="course-wizard-thumbnail"></div>
      );
    }.bind(this);
  }
}

Thumbnail.PropTypes = {
  actions: PropTypes.object.isRequired,
  name: PropTypes.string.isRequired,
  uniqueStore: PropTypes.object.isRequired,
};