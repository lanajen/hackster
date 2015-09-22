import React from 'react';
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

  handleImages(e) {
    this.preventEvent(e);

    let files = e.target.files,
        storeIndex = this.props.editor.imageToolbarData.storeIndex,
        filteredFiles;

    files = Array.prototype.slice.call(files);
    filteredFiles = _.filter(files, function(file) {
      if(Helpers.isImageValid(file.type)) {
        return file;
      } else {
        return false;
      }
    });

    ImageUtils.handleImagesAsync(files, function(map) {
      this.props.actions.addImagesToCarousel(map, storeIndex);
      this.props.actions.forceUpdate(true);
      this.props.actions.toggleImageToolbar(false, {});
    }.bind(this));

    React.findDOMNode(this.refs.imageToolbarInput).value = '';
  },

  handleAddImageClick(e) {
    this.preventEvent(e);
    React.findDOMNode(this.refs.imageToolbarInput).click();
  },

  handleDeleteImage(e) {
    this.preventEvent(e);
    let depth = this.props.editor.imageToolbarData.depth;
    let storeIndex = this.props.editor.imageToolbarData.storeIndex;
    this.props.actions.deleteImagesFromCarousel([], depth, storeIndex);
    this.props.actions.forceUpdate(true);
    this.props.actions.toggleImageToolbar(false, {});
  },

  handleDeleteVideo(e) {
    this.preventEvent(e);
    let storeIndex = this.props.editor.imageToolbarData.storeIndex;
    this.props.actions.deleteComponent(storeIndex);
    this.props.actions.forceUpdate(true);
    this.props.actions.toggleImageToolbar(false, {});
  },

  handleMouseMove(e) {
    this.preventEvent(e);

    if(e.nativeEvent.offsetY >= 484) {
      this.props.actions.toggleImageToolbar(false, {});
    }
  },

  handleMouseOut(e) {
    let node = React.findDOMNode(e.target);
    /** 
     * Handles releasing the ImageToolbar overlay component.
     * First we handle an edge case where the mouse was in a button then placed outside the CE. 
     * Secondly we handle ignoring any elements inside the Carousel.
    **/
    if((node.nodeName === 'SPAN' || node.nodeName === 'BUTTON') 
       && e.nativeEvent.relatedTarget && e.nativeEvent.relatedTarget.id
       && e.nativeEvent.relatedTarget.id === 'react-main-mount'
       && this.props.editor.showImageToolbar === true) {
      this.props.actions.toggleImageToolbar(false, {});
    } else if(node.nodeName === 'DIV' && node.classList.contains('react-editor-image-overlay') 
       && (e.nativeEvent.relatedTarget && !e.nativeEvent.relatedTarget.classList.contains('reit-controls'))
       && (e.nativeEvent.relatedTarget && e.nativeEvent.relatedTarget.nodeName !== 'BUTTON')
       && (e.nativeEvent.relatedTarget && !Utils.getRootOverlayElement(e.nativeEvent.relatedTarget).classList.contains('reit-toolbar'))
       && this.props.editor.showImageToolbar === true) {
      this.props.actions.toggleImageToolbar(false, {});
    }
  },

  handleClick(e) {
    let { node } = this.props.editor.imageToolbarData;
    node.focus();
  },

  getStyles() {
    let data = this.props.editor.imageToolbarData;
    let styles = {
      top: data.top,
      marginLeft: 20,
      width: data.width,
      height: (parseInt(data.height, 10) - 27)
    };
    return styles;
  },

  render: function() {
    let style, toolbar;

    if(this.props.editor && this.props.editor.showImageToolbar === true) {
      style = this.getStyles();
    }

    toolbar = this.props.editor.imageToolbarData.type === 'carousel'
               ? (<div className="reit-toolbar">
                    <IconButton iconStyle={{color: '#80DEEA'}} iconClassName="reit-button fa fa-plus" tooltip="Add an Image" onClick={this.handleAddImageClick}/>
                    <IconButton iconStyle={{color: '#80DEEA'}} iconClassName="reit-button fa fa-trash-o" tooltip="Delete this Image" onClick={this.handleDeleteImage}/>
                    
                  </div>)
               : this.props.editor.imageToolbarData.type === 'video' 
               ? (<div className="reit-toolbar">
                    <IconButton iconStyle={{color: '#80DEEA'}} iconClassName="reit-button fa fa-trash-o" tooltip="Delete Video" onClick={this.handleDeleteVideo}/>
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
// <IconButton iconStyle={{color: '#80DEEA'}} iconClassName="reit-button fa fa-th-list" tooltip="Edit Carousel"/>
export default ImageToolbar;