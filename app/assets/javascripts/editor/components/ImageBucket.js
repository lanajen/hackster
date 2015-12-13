import React from 'react';
import DropZone from '../../reusable_components/DropZone';
import Button from './ToolbarButton';

var ImageBucket = React.createClass({

  onDrop(e) {
    // console.log(e);
  },

  onCloseContainerButton() {
    this.props.hideFolder();
  },

  render: function() {
    let containerClassList = this.props.show ? 'react-editor-image-container show' : 'react-editor-image-container hide';

    return (
      <div className={containerClassList}>
        <DropZone className="react-editor-image-wrapper" onDrop={this.onDrop}>
          <div className="image-bucket-header">
            <h3>Media</h3>
            <Button icon="fa fa-arrow-left" onClick={this.onCloseContainerButton}/>
          </div>

          <div className="image-bucket-content">
            <div className="testeroo"></div>
            <div className="testeroo"></div>

          </div>

          <div className="image-bucket-footer">
            <Button classList="btn-success" icon="fa fa-plus" />
            <Button classList="btn-danger" icon="fa fa-minus" />
          </div>
        </DropZone>
      </div>
    );
  }

});

export default ImageBucket;