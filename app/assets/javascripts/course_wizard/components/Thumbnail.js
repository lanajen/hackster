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
      'Class': this._createPromotionThumb(this.props),
      'University': this._createUniversityThumb(this.props)
    };

    let view = views[name] ? views[name] : views['Generic'];

    return (
      <div>
        {view()}
        <div className="change-link-wrapper">
          <a href="javascript:void(0);" onClick={this.handleChangeLinkClick}>Change</a>
        </div>
      </div>
    );
  }

  _createUniversityThumb(props) {
    const { imageData, avatar_url, city, country, full_name } = props.uniqueStore;
    return function() {
      return (
        <div className="course-wizard-thumbnail">
          <img src={avatar_url ? avatar_url : imageData ? imageData.dataUrl : ''} />
          <div className="thumbnail-details">
            <h4>{full_name}</h4>
            <div className="smaller text-muted">
              <i className="fa fa-map-marker" />
              <span>{`${city}, ${country}`}</span>
            </div>
          </div>
        </div>
      );
    }.bind(this);
  }

  _createCourseThumb(props) {
    const { imageData, full_name, course_number, mini_resume, cover_image_url } = props.uniqueStore;
    let courseNumber = course_number ?
                        (<p>{course_number}</p>) : null;
    let pitch = mini_resume ? (<p className='smaller text-muted'>{mini_resume}</p>) : null;

    return function() {
      return (
        <div className="course-wizard-thumbnail">
          <div className="thumbnail-details">
            <h4>{full_name}</h4>
            {courseNumber}
            {pitch}
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
          <h4>{full_name}</h4>
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