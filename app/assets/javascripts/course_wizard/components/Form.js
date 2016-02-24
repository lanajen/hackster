import React, { Component, PropTypes } from 'react';
import ReactDOM from 'react-dom';
import ImageUploader from '../../image_uploader/app';

export default class Form extends Component {
  constructor(props) {
    super(props);

    this.toggleToSearch = this.toggleToSearch.bind(this);
    this.handleImageData = this.handleImageData.bind(this);
    this.handleSubmitClick = this.handleSubmitClick.bind(this);
    this.handleImageUploading = this.handleImageUploading.bind(this);

    this.state = { errors: [], imageData: null, imageUploading: false };
  }

  toggleToSearch() {
    this.props.toggleToSearch();
  }

  handleImageData(data) {
    this.setState({ imageData: data });
  }

  handleSubmitClick(e) {
    e.preventDefault();

    let errors = this._assembleErrors();

    if(errors.length) {
      this.setState({ errors: errors });
    } else {
      this.props.postForm(this._assembleForm(), this.props.endpoint, this.state.imageData);
    }
  }

  _assembleErrors() {
    let refs = Object.keys(this.refs);
    let errors = [];

    refs.forEach(ref => {
      let node = ReactDOM.findDOMNode(this.refs[ref]);
      if(!node.value.length) {
        errors.push(ref);
      }
    });

    if(this.props.image && !this.state.imageData) {
      errors.push(this.props.image['human_file_type']);
    }
    return errors;
  }

  _assembleForm() {
    let form = { type: this.props.type };
    let keys = this.props.keys;
    let refs = Object.keys(this.refs);

    refs.forEach(ref => {
      let node = ReactDOM.findDOMNode(this.refs[ref]);
      let value = node.nodeName === 'SELECT' ? node.options[node.selectedIndex].value : node.value;
      form[keys[ref]] = value;
    });

    if(this.props.image) {
      form[keys[this.props.image['human_file_type']]] = this.state.imageData.id;
    }

    if(this.props.parentId) {
      form['parent_id'] = this.props.parentId;
    }

    return form;
  }

  handleImageUploading(bool) {
    this.setState({ imageUploading: bool });
  }

  render() {
    let { image, inputs, selections, textareas, imageUploadData } = this.props;

    let Inputs = inputs.map((input, index) => {
      return (
        <div key={index} className="course-wizard-form-item form-group">
          <div className="col-sm-4">
            <label className="control-label">{input}</label>
          </div>
          <div className="col-sm-8">
            <input ref={input} className="form-control" type="text" />
          </div>
        </div>
      );
    });

    let Selections = selections
                   ? selections.map((selection, index) => {
                      let options = selection.options && selection.options.length
                                  ? selection.options.map((option, i) => {
                                      return (<option key={i} value={option}>{option}</option>);
                                    })
                                  : (null);
                      return (
                        <div key={index} className="course-wizard-form-item form-group">
                          <div className="col-sm-4">
                            <label className="control-label">{selection.label}</label>
                          </div>
                          <div className="col-sm-8">
                            <select ref={selection.label} className="select optional form-control" name={selection.label}>
                              {options}
                            </select>
                          </div>
                        </div>
                      );
                    })
                   : (null);

    let Textarea = textareas
                 ? textareas.map((textarea, index) => {
                    return (
                      <div key={index} className="course-wizard-form-item form-group">
                        <div className="col-sm-4">
                          <label className="control-label">{textarea.label}</label>
                        </div>
                        <div className="col-sm-8">
                          <textarea ref={textarea.label} className="form-control" name={textarea.label} rows={textarea.rows || 3} maxLength={140} />
                        </div>
                      </div>
                    );
                   })
                 : (null);

    let Image = image
             ? (<ImageUploader locals={image} {...imageUploadData} getImageData={this.handleImageData} imageUploading={this.handleImageUploading} />)
             : (null);

    let errorMessage = this.state.errors && this.state.errors.length
                     ? (<div className="text-right text-danger" style={{ fontSize: '0.8em', padding: '2% 0' }}>{ `Please fill in the following: ${this.state.errors.join(', ')}`}</div>)
                     : (null);

    return (
      <form className="course-wizard-form form-horizontal" action="">
        {Inputs}
        {Selections}
        {Textarea}
        {Image}
        <div className="continue-btn">
          <span>
            {this.props.search ? <a href="javascript:void(0);" className="btn btn-link btn-sm" tabIndex='-1' onClick={this.toggleToSearch}>Back to search</a> : null}
          </span>
          <button className="btn btn-primary btn-sm" disabled={this.state.imageUploading} onClick={this.handleSubmitClick}>Continue</button>
        </div>
        {errorMessage}
      </form>
    );
  }
}

Form.PropTypes = {
  endpoint: PropTypes.string.isRequired,
  image: PropTypes.object,
  imageUploadData: PropTypes.object.isRequired,
  inputs: PropTypes.array.isRequired,
  keys: PropTypes.object.isRequired,
  parentId: PropTypes.number,
  postForm: PropTypes.func.isRequired,
  search: PropTypes.bool.isRequired,
  selections: PropTypes.object,
  textareas: PropTypes.object,
  toggleToSearch: PropTypes.func.isRequired,
  type: PropTypes.string.isRequired
};