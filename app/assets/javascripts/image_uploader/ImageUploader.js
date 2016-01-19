import React, {Component, PropTypes} from 'react';
import ReactDOM from 'react-dom';
import Helpers from '../utils/Helpers';
import { Dialog } from 'material-ui';
import ProgressBar from './ProgressBar';

export default class ImageUploader extends Component {
  constructor(props) {
    super(props);
    this.handleSelectPictureClick = this.handleSelectPictureClick.bind(this);
    this.handleImageUpload = this.handleImageUpload.bind(this);
    this.handleRemoteLinkClick = this.handleRemoteLinkClick.bind(this);
    this.handleRemoteButtonClick = this.handleRemoteButtonClick.bind(this);
    this.handleDialogDismiss = this.handleDialogDismiss.bind(this);
    this.handleRemoteInputKeyPress = this.handleRemoteInputKeyPress.bind(this);

    this._createInlineMarkup = this._createInlineMarkup.bind(this);
    this._createStackedMarkup = this._createStackedMarkup.bind(this);

    this.state = { showDialog: false };
  }

  handleSelectPictureClick(e) {
    e.preventDefault();
    ReactDOM.findDOMNode(this.refs.fileInput).click();
  }

  handleImageUpload(e) {
    e.preventDefault();
    let file = e.dataTransfer ? e.dataTransfer.files : e.target.files;
    Helpers.isImageValid(file[0].type) ? this.props.handleImageUpload(file) : console.log('NOT A VALID IMAGE {HANDLE ERROR}!', file);
  }

  handleRemoteLinkClick(e) {
    e.preventDefault();
    this.setState({ showDialog: true });
  }

  handleRemoteButtonClick(e) {
    e.preventDefault();
    let input = ReactDOM.findDOMNode(this.refs.remoteUploadInput);

    Helpers.isImageUrlValid(input.value) ? this.props.handleRemoteUpload(input.value, this.props.locals.attribute_type) : console.log('NOT A VALID IMAGE {HANDLE ERROR!}');
    this.handleDialogDismiss();
  }

  handleRemoteInputKeyPress(e) {
    if(e.keyCode === 13) {
      this.handleRemoteButtonClick(e);
    }
  }

  handleDialogDismiss() {
    this.setState({ showDialog: false });
  }

  render() {
    let { locals, imageData, isWorking } = this.props;
    let { file_type, human_file_type, attribute_type, help_block, model, image_link } = locals;
    let label = human_file_type
              ? (<div className="col-md-4">
                   <label className="control-label">{human_file_type}</label>
                 </div>)
              : (null);

    let imagePreview = imageData.image_link && !imageData.id
                     ? (<img style={{ paddingRight: 5 }} src={imageData.image_link} alt={imageData.file_name || ""} />)
                     : (imageData.dataUrl || imageData.image_link) && imageData.id
                     ? (<span style={{ paddingRight: 5 }} className="inserted">
                          <img width={60} src={imageData.dataUrl || imageData.image_link} alt={imageData.file_name || ""} />
                          <input type="hidden" name={`${model}[${attribute_type}_id]`} className="inserted" value={imageData.id} />
                        </span>)
                     : (null);

    let buttonLabel = isWorking
                    ? 'Uploading image'
                    : imageData.image_link || imageData.dataUrl
                    ? 'Change picture'
                    : 'Select picture';

    let actions = isWorking
                ? (<ProgressBar />)
                : (<div className="btn-group">
                    <a href="javascript:void(0);" className="btn btn-default btn-sm browse" onClick={this.handleSelectPictureClick}>{buttonLabel}</a>
                    <a href="javascript:void(0);" className="btn btn-default btn-sm url" onClick={this.handleRemoteLinkClick}>
                      <i className="fa fa-link"></i>
                    </a>
                  </div>);

    let dialog = this.state.showDialog
              ? (<Dialog open={this.state.showDialog} contentStyle={{ width: 600, display: 'flex' }} bodyStyle={{ width: 600, padding: 10, display: 'flex', flexDirection: 'column' }} onRequestClose={this.handleDialogDismiss}>
                  <button style={{ alignSelf: 'flex-end', paddingBottom: 10 }} className="close btn-close unselectable" onClick={this.handleRemoteButtonClick}>x</button>
                  <div style={{ display: 'flex', flexDirection: 'row', padding: '10px 40px 40px 40px' }}>
                    <input ref="remoteUploadInput" style={{ borderTopRightRadius: 0, borderBottomRightRadius: 0 }} className="form-control" type="text" placeholder="Enter image url" onKeyUp={this.handleRemoteInputKeyPress} />
                    <button style={{ borderTopLeftRadius: 0, borderBottomLeftRadius: 0, height: 34, fontSize: 14 }} className="btn btn-primary" onClick={this.handleRemoteButtonClick}>Grab image</button>
                  </div>
                 </Dialog>)
              : (null);

    let markups = {
      'base_article': this._createInlineMarkup(locals, label, imagePreview, actions, dialog),
      'challenge_idea': this._createStackedMarkup(locals, imagePreview, actions, dialog),
    };

    let markup = markups[model]();
    return (markup);
  }

  _createInlineMarkup(locals, label, imagePreview, actions, dialog) {
    let { human_file_type, file_type, help_block } = locals;
    return function() {
      return (
        <div className="form-group">
          <input ref="fileInput" style={{display: 'none'}} type="file" multiple="false" onChange={this.handleImageUpload} />
          {label}
          <div className={human_file_type ? "col-md-8" : ""}>
            <span className={"image-preview preview " + file_type}>{imagePreview}</span>
            {actions}
            <p className="help-block">{help_block}</p>
            {dialog}
          </div>
        </div>
      );
    }.bind(this);
  }

  _createStackedMarkup(locals, imagePreview, actions, dialog) {
    let { human_file_type, file_type, help_block, errors } = locals;
    return function() {
      let error = errors.image_id && errors.image_id.length ? (<p className="help-block">{errors.image_id[0]}</p>) : null;
      return (
        <div className={error ? 'form-group has-error' : 'form-group'}>
          <input ref="fileInput" style={{display: 'none'}} type="file" multiple="false" onChange={this.handleImageUpload} />
          <label className="control-label">
            <abbr title="required">*</abbr>
             Add an Image
          </label>
          <div className="image">
            <span className={"image-preview preview " + file_type}>{imagePreview}</span>
            {actions}
          </div>
          <p className="help-block">{help_block}</p>
          {error}
          {dialog}
        </div>
      );
    }.bind(this);
  }
}

ImageUploader.PropTypes = {
  locals: PropTypes.object.isRequired,
  handleImageUpload: PropTypes.func.isRequired,
  handleRemoteUpload: PropTypes.func.isRequired,
  imageData: PropTypes.object.isRequired,
  isWorking: PropTypes.bool.isRequired
};