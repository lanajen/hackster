import React from 'react';
import ReactDOM from 'react-dom';
import _ from 'lodash';
import { IconButton } from 'material-ui';
import Utils from '../utils/DOMUtils';
import ImageUtils from '../../utils/Images';
import Helpers from '../../utils/Helpers';

const ImageToolbar = React.createClass({

  preventEvent(e) {
    e.preventDefault();
    e.stopPropagation();
  },

  handleUnsavedChanges() {
    if(this.props.editor.hasUnsavedChanges === false) {
      this.props.actions.hasUnsavedChanges(true);
    }
  },

  handleImages(e) {
    this.preventEvent(e);
    let files = e.dataTransfer ? e.dataTransfer.files : e.target.files,
        storeIndex = this.props.editor.imageToolbarData.storeIndex,
        filteredFiles;

    files = Array.prototype.slice.call(files);
    filteredFiles = _.filter(files, file => {
      if(Helpers.isImageValid(file.type)) {
        return true;
      } else {
        let msg = file.name ? file.name + ' is not a valid image!' : 'Sorry, not a valid image';
        this.props.actions.toggleErrorMessenger(true, msg);
        return false;
      }
    });

    if(!filteredFiles.length) {
      return;
    }

    ImageUtils.handleImagesAsync(filteredFiles, function(map) {
      this.props.actions.isDataLoading(true);
      this.props.actions.addImagesToCarousel(map, storeIndex);
      this.props.actions.forceUpdate(true);
      this.props.actions.toggleImageToolbar(false, {});
      this.handleUnsavedChanges();

      /** Upload files to AWS. */
      this.props.actions.uploadImagesToServer(
        map,
        storeIndex,
        this.props.editor.lastMediaHash,
        this.props.editor.S3BucketURL,
        this.props.editor.AWSAccessKeyId,
        this.props.editor.csrfToken,
        this.props.editor.projectId
      );

    }.bind(this));

    ReactDOM.findDOMNode(this.refs.imageToolbarInput).value = '';
  },

  handleAddImageClick(e) {
    this.preventEvent(e);
    ReactDOM.findDOMNode(this.refs.imageToolbarInput).click();
  },

  handleDeleteImage(e) {
    this.preventEvent(e);
    let depth = this.props.editor.imageToolbarData.depth;
    let storeIndex = this.props.editor.imageToolbarData.storeIndex;
    this.props.actions.deleteImagesFromCarousel([], depth, storeIndex);
    this.props.actions.forceUpdate(true);
    this.props.actions.toggleImageToolbar(false, {});
    this.handleUnsavedChanges();
  },

  handleCarouselEditorShow() {
    this.props.showEditor();
  },

  handleDeleteVideo(e) {
    this.preventEvent(e);
    let storeIndex = this.props.editor.imageToolbarData.storeIndex;
    this.props.actions.deleteComponent(storeIndex);
    this.props.actions.forceUpdate(true);
    this.props.actions.toggleImageToolbar(false, {});
    this.handleUnsavedChanges();
  },

  handleMouseMove(e) {
    this.preventEvent(e);

    if(e.nativeEvent.offsetY >= 484) {
      this.props.actions.toggleImageToolbar(false, {});
    }
  },

  handleMouseOut(e) {
    let node = ReactDOM.findDOMNode(e.target);
    /**
     * Handles releasing the ImageToolbar overlay component.
     * First we handle an edge case where the mouse was in a button then placed outside the CE.
     * Secondly we handle ignoring any elements inside the Carousel.
    **/
    if((node.nodeName === 'SPAN' || node.nodeName === 'BUTTON' || Utils.isChildOfParentByClass(node, 'react-editor-image-overlay'))
       && (e.nativeEvent.relatedTarget && e.nativeEvent.relatedTarget.id && e.nativeEvent.relatedTarget.id === 'react-main-mount'
           || e.nativeEvent.relatedTarget && e.nativeEvent.relatedTarget.classList.contains('row')
           || e.nativeEvent.relatedTarget && e.nativeEvent.relatedTarget.classList.contains('box-content'))
       && this.props.editor.showImageToolbar === true) {
      this.props.actions.toggleImageToolbar(false, {});
    this.props.actions.updateComponent(this.props.editor.imageToolbarData.storeIndex);
    } else if(node.nodeName === 'DIV' && node.classList.contains('react-editor-image-overlay')
       && (e.nativeEvent.relatedTarget && !e.nativeEvent.relatedTarget.classList.contains('reit-controls'))
       && (e.nativeEvent.relatedTarget && e.nativeEvent.relatedTarget.nodeName !== 'BUTTON')
       && (e.nativeEvent.relatedTarget && !Utils.getRootOverlayElement(e.nativeEvent.relatedTarget).classList.contains('reit-toolbar'))
       && this.props.editor.showImageToolbar === true) {
      this.props.actions.toggleImageToolbar(false, {});
      this.props.actions.updateComponent(this.props.editor.imageToolbarData.storeIndex);
    }
  },

  handleClick(e) {
    let { node } = this.props.editor.imageToolbarData;
    node.focus();
  },

  getStyles() {
    let data = this.props.editor.imageToolbarData;
    let styles = {
      top: 0,
      marginLeft: 0,
      width: data.width || '100%',
      height: (parseInt(data.height, 10) - 27) || '100%'
    };
    return styles;
  },

  render: function() {
    let style, toolbar, buttonStyle, buttonIconStyle;

    if(this.props.editor && this.props.editor.showImageToolbar === true) {
      style = this.getStyles();
    }
    buttonStyle = {
      borderRadius: '4px',
      background: null
    };
    buttonIconStyle = {
      color: '#fff',
      fontSize: '2rem'
    }

    toolbar = this.props.editor.imageToolbarData.type === 'carousel'
               ? (<div className="reit-toolbar">
                    <IconButton style={Object.assign({}, buttonStyle, { marginRight: '10px' })} className="btn btn-primary" iconStyle={buttonIconStyle} iconClassName="reit-button fa fa-plus" tooltip="Add an Image" onClick={this.handleAddImageClick}/>
                    <IconButton style={Object.assign({}, buttonStyle, { marginRight: '10px' })} className="btn btn-primary" iconStyle={buttonIconStyle} iconClassName="reit-button fa fa-exchange" tooltip="Reorder Images" onClick={this.handleCarouselEditorShow}/>
                    <IconButton style={Object.assign({}, buttonStyle)} className="btn btn-danger" iconStyle={buttonIconStyle} iconClassName="reit-button fa fa-trash-o" tooltip="Delete this Image" disabled={this.props.editor.isDataLoading} onClick={this.handleDeleteImage}/>
                  </div>)
               : this.props.editor.imageToolbarData.type === 'video'
               ? (<div className="reit-toolbar">
                    <IconButton style={Object.assign({}, buttonStyle)} className="btn btn-danger" iconStyle={buttonIconStyle} iconClassName="reit-button fa fa-trash-o" tooltip="Delete Video" onClick={this.handleDeleteVideo}/>
                  </div>)
               : (null);

    return (
      <div style={style} className="react-editor-image-overlay" onMouseMove={this.handleMouseMove} onMouseOut={this.handleMouseOut} onClick={this.handleClick}>
        {toolbar}
        <input ref="imageToolbarInput" style={{display: 'none'}} type="file" multiple="true" onChange={this.handleImages}/>
      </div>
    );
  }

});

export default ImageToolbar;