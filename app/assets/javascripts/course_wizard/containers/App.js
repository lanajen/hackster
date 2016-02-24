import React, { Component, PropTypes } from 'react';
import { bindActionCreators } from 'redux';
import { connect } from 'react-redux';
import * as Actions from '../actions';
import Step from '../components/Step';
import { Countries } from '../../utils/Constants';
import { getApiPath } from '../../utils/Utils'

const Steps = [
  {
    name: 'University',
    type: 'University',
    form: {
      inputs: ['Name', 'City'],
      selections: [{ label: 'Country', options: Countries }],
      image: {
        file_type: null,
        human_file_type: 'Logo',
        attribute_type: 'avatar',
        help_block: null,
        model: 'base_article',
        image_link: null
      },
      keys: { Name: 'full_name', 'City': 'city', 'Country': 'country', 'Logo': 'avatar_id' },
      endpoint: `${getApiPath()}/private/groups`
    },
    search: true
  },
  {
    name: 'Course',
    type: 'Course',
    form: {
      inputs: ['Name', 'Course #'],
      textareas: [{ label: 'Pitch', rows: 3 }],
      keys: { Name: 'full_name', ['Course #']: 'course_number', Pitch: 'mini_resume' },
      endpoint: `${getApiPath()}/private/groups`
    },
    search: true
  },
  {
    name: 'Class',
    type: 'Promotion',
    form: {
      inputs: ['Year or semester'],
      image: null,
      keys: { 'Year or semester': 'full_name' },
      endpoint: `${getApiPath()}/private/groups`
    },
    search: false
  }
];

class App extends Component {
  constructor(props) {
    super(props);

    this.handleInviteMembersClick = this.handleInviteMembersClick.bind(this);
  }

  handleInviteMembersClick(e) {
    e.preventDefault();

  }

  render() {
    let completed = this._isComplete();

    let steps = Steps.map((step, index) => {
      let { name, type, form, search } = step;
      let prev = Steps[index-1];
      if( index === 0 || this.props.store[prev.name.toLowerCase()] ) {
        return (<Step key={index} name={name} type={type} form={index > 0 ? { ...form, parentId: this.props.store[prev.name.toLowerCase()].id } : form} search={search} {...this.props} />);
      } else {
        return null;
      }
    }).filter(step => step !== null);

    let completedButton = completed
                        ? (<div className="completed-button-wrapper">
                            <a href={`/groups/${this.props.store.promotion.id}`} className="btn btn-success">Complete</a>
                          </div>)
                        : (null);

    return (
      <div className="row">
        <div className="col-md-6 col-md-offset-3 col-sm-8 col-sm-offset-2">
          <div className='course-wizard-wrapper box allow-overflow'>
            <div className="box-title">
              <h2>Create a new course page</h2>
            </div>
            <div className="box-content">
              <div className="course-wizard">
                {steps}
                {completedButton}
              </div>
            </div>
          </div>
        </div>
      </div>
    );
  }

  _isComplete() {
    let keys = Object.keys(this.props.store);
    let completed = keys.filter(key => this.props.store[key] === null);
    return !completed.length;
  }
}

App.PropTypes = {
  S3BucketURL: PropTypes.string.isRequired,
  AWSAccessKeyId: PropTypes.string.isRequired
};

function mapStateToProps(state) {
  return {
    store: state
  };
}

function mapDispatchToProps(dispatch) {
  return { actions: bindActionCreators(Actions, dispatch) };
}

export default connect(mapStateToProps, mapDispatchToProps)(App);