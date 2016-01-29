import React, { Component, PropTypes } from 'react';
import Search from './Search';
import Thumbnail from './Thumbnail';

export default class Step extends Component {
  constructor(props) {
    super(props);
  }

  render() {
    const { actions, S3BucketURL, AWSAccessKeyId, form, search, name, store, type } = this.props;
    const uniqueStore = this.props.store[type.toLowerCase()];
    const imageUploadData = { S3BucketURL, AWSAccessKeyId };

    let body = uniqueStore
             ? (<Thumbnail actions={actions}
                           name={name}
                           uniqueStore={uniqueStore} />)
             : (<Search actions={actions}
                        name={name}
                        type={type}
                        value={uniqueStore}
                        form={form}
                        search={search}
                        store={store}
                        imageUploadData={imageUploadData}/>);

    return (
      <div className="course-wizard-step">
        <label>What's the {name}?</label>
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
  type: PropTypes.string.isRequired
};