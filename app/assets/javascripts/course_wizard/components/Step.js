import React, { Component, PropTypes } from 'react';
import Search from './Search';
import Thumbnail from './Thumbnail';

export default class Step extends Component {
  constructor(props) {
    super(props);
  }

  render() {
    const { actions, S3BucketURL, AWSAccessKeyId, form, search, name } = this.props;
    const uniqueStore = this.props.store[name.toLowerCase()];
    const imageUploadData = { S3BucketURL, AWSAccessKeyId };

    let body = uniqueStore
             ? (<Thumbnail actions={actions}
                           name={name}
                           uniqueStore={uniqueStore} />)
             : (<Search actions={actions}
                        name={name}
                        value={uniqueStore}
                        form={form}
                        search={search}
                        imageUploadData={imageUploadData}/>);

    return (
      <div className="course-wizard-step">
        <h3>{name}</h3>
        {body}
      </div>
    );
  }
};

Step.PropTypes = {
  actions: PropTypes.object.isRequired,
  AWSAccessKeyId: PropTypes.string.isRequired,
  form: PropTypes.object.isRequired,
  name: PropTypes.string.isRequired,
  S3BucketURL: PropTypes.string.isRequired,
  search: PropTypes.bool.isRequired,
  store: PropTypes.object.isRequired,
};