import React, { Component, PropTypes } from 'react';
import { bindActionCreators } from 'redux';
import { connect } from 'react-redux';
import * as Actions from '../actions';
import Step from '../components/Step';
import { Countries } from '../../utils/Constants';

const Steps = [
  {
    name: 'University',
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
      endpoint: '/api/v1/groups'
    },
    search: true
  },
  {
    name: 'Course',
    form: {
      inputs: ['Name', 'Course #'],
      textareas: [{ label: 'Pitch', rows: 3 }],
      image: {
        file_type: null,
        human_file_type: 'Cover image',
        attribute_type: 'cover_image',
        help_block: null,
        model: 'base_article',
        image_link: null
      },
      keys: { Name: 'full_name', ['Course #']: 'course_number', Pitch: 'mini_resume', ['Cover image']: 'cover_image_id' },
      endpoint: '/api/v1/groups'
    },
    search: true
  },
  {
    name: 'Promotion',
    form: {
      inputs: ['Name'],
      image: null,
      keys: { Name: 'full_name' },
      endpoint: '/api/v1/groups'
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
      let { name, form, search } = step;
      let prev = Steps[index-1];
      if( index === 0 || this.props.store[prev.name.toLowerCase()] ) {
        return (<Step key={index} name={name} form={index > 0 ? { ...form, parentId: this.props.store[prev.name.toLowerCase()].id } : form} search={search} {...this.props} />);
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
      <div className='course-wizard-wrapper'>
        <div className="course-wizard">
          {steps}
          {completedButton}
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