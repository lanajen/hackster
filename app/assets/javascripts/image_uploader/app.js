import React, {Component, PropTypes} from 'react';
import ReactDOM from 'react-dom';
import DropZone from './DropZone';
import ImageUploader from  './ImageUploader';
import ImageHelpers from '../utils/Images';

export default class App extends Component {
  constructor(props) {
    super(props);
    this.handleImageUpload = this.handleImageUpload.bind(this);
    this.handleRemoteUpload = this.handleRemoteUpload.bind(this);

    this.state = { imageData: {}, csrfToken: null, isWorking: null };
  }

  componentWillMount() {
    if(document) {
      let metaList = document.querySelectorAll('meta');
      let csrfToken;
      [].slice.apply(metaList).forEach(el => {
        if(el.name === 'csrf-token') { csrfToken = el.content; }
      });
      this.setState({ csrfToken: csrfToken });
    }

    if(this.props.locals.image_data) {
      this.setState({ imageData: this.props.locals.image_data });
    } else if(this.props.locals.image_link) {
      this.setState({ imageData: { image_link: this.props.locals.image_link } });
    }
  }

  componentWillUpdate(nextProps, nextState) {
    if(nextState.isWorking !== this.state.isWorking && this.props.imageUploading) {
      this.props.imageUploading(nextState.isWorking);
    }
  }

  handleImageUpload(file) {
    let fileData = {};
    this.setState({ isWorking: true });

    return ImageHelpers.promisifiedFileReader(file[0])
      .then(fileReaderData => {
        fileData = { ...fileReaderData };
        let name = file[0].name || 'tmp_image_0';
        name = name.substring(0, 254);
        return ImageHelpers.getS3AuthData(name);
      })
      .then(S3Data => {
        return ImageHelpers.postToS3(S3Data, fileData, this.props.S3BucketURL, this.props.AWSAccessKeyId);
      })
      .then(url => {
        let fileType = this.props.locals.attribute_type;
        return ImageHelpers.postURLToServer(url, null, this.state.csrfToken, fileType, fileType + '-upload');
      })
      .then(response => {
        let imageData = { ...fileData, ...response.body };
        this.setState({ imageData: imageData, isWorking: false });

        if(this.props.getImageData) {
          this.props.getImageData(imageData);
        }
      })
      .catch(err => {
        this.setState({ isWorking: false });
        console.error('Image Upload ', err);
      });
  }

  handleRemoteUpload(url, fileType) {
    let fileData = {};

    this.setState({ isWorking: true });

    return ImageHelpers.postRemoteURL(url, fileType, this.state.csrfToken)
      .then(body => {
        fileData = { id: body.id, image_link: url };
        return ImageHelpers.pollJob(body['job_id']);
      })
      .then(status => {
        let imageData = { ...this.state.imageData, ...fileData, dataUrl: null };
        this.setState({ imageData: imageData, isWorking: false });

        if(this.props.getImageData) {
          this.props.getImageData(imageData);
        }
      })
      .catch(err => {
        this.setState({ isWorking: false });
        console.log('Remote Upload Error ', err);
      });
  }

  render() {
    return (
      <DropZone multiple={false} onDrop={this.handleImageUpload}>
        <ImageUploader handleImageUpload={this.handleImageUpload} handleRemoteUpload={this.handleRemoteUpload} imageData={this.state.imageData} isWorking={this.state.isWorking} { ...this.props } />
      </DropZone>
    );
  }
}

App.PropTypes = {
  getImageData: PropTypes.func,
  imageUploading: PropTypes.func,
  locals: PropTypes.object.isRequired,
  S3BucketURL: PropTypes.string.isRequired,
  AWSAccessKeyId: PropTypes.string.isRequired,
};