import React from 'react';
import _ from 'lodash';
import { IconButton } from 'material-ui';
import Utils from '../../utils/DOMUtils';
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
        node = this.props.editor.imageToolbarData.node,
        depth = this.props.editor.imageToolbarData.depth,
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
      this.props.actions.addImagesToCarousel(map, depth);
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
    this.props.actions.deleteImagesFromCarousel([], depth);
    this.props.actions.forceUpdate(true);
    this.props.actions.toggleImageToolbar(false, {});
  },

  handleDeleteVideo(e) {
    this.preventEvent(e);
    let depth = this.props.editor.imageToolbarData.depth;
    this.props.actions.removeBlockElements([ { hash: '', depth: depth } ]);
    this.props.actions.forceUpdate(true);
    this.props.actions.toggleImageToolbar(false, {});
  },

  handleMouseMove(e) {
    this.preventEvent(e);

    if(e.nativeEvent.offsetY >= 484) {
      this.props.actions.toggleImageToolbar(false, {});
    }
  },

  getStyles() {
    let data = this.props.editor.imageToolbarData;
    let styles = {
      top: data.top,
      marginLeft: data.left,
      width: data.width,
      height: data.height
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
      <div style={style} className="react-editor-image-overlay" onMouseMove={this.handleMouseMove}>
        {toolbar}
        <input ref="imageToolbarInput" style={{display: 'none'}} type="file" multiple="true" onChange={this.handleImages}/>
      </div>
    );
  }

});
// <IconButton iconStyle={{color: '#80DEEA'}} iconClassName="reit-button fa fa-th-list" tooltip="Edit Carousel"/>  PUT THIS AT THE END OF CAROUSEL.
export default ImageToolbar;