import React from 'react';
import { createRandomNumber } from '../../utils/Helpers';
import { bindActionCreators } from 'redux';
import { Connector } from 'redux/react';
import Toolbar from './Toolbar';
import ImageBucket from './ImageBucket';
import DropZone from '../../reusable_components/DropZone';
import ContentEditable from '../../reusable_components/ContentEditable';
import * as ToolbarActions from '../actions/ToolbarActions';
import * as ImageBucketActions from '../actions/ImageBucketActions';
import * as EditorActions from '../actions/EditorActions';


var Editor = React.createClass({

  onDrop(e) {
    console.log(e);
  },

  onContentEditableChange(html) {
    this.props.setHTML(html);
  },

  onTextSelect(data) {
    this.props.setSelectedText(data);
  },

  isTextSelected(bool) {
    this.props.isTextSelected(bool);
  },

  render: function() {
    // console.log(this.props);
    return (
      <Connector select={(state) => {
        return {
          toolbar: state.toolbar,
          imageBucket: state.imageBucket,
          editor: state.editor
        }; 
      }}>
        {this.renderChild}
      </Connector>
    );
  },

  renderChild({toolbar, imageBucket, editor, dispatch}) {
    return (
      <div className="react-editor-wrapper">
        <ImageBucket show={imageBucket.show} {...bindActionCreators(ImageBucketActions, dispatch)} />
        <Toolbar toolbar={toolbar} isImageBucketOpen={imageBucket.show}  editor={editor} {...bindActionCreators(Object.assign({}, ToolbarActions, ImageBucketActions, EditorActions), dispatch)} />

        <DropZone className="box" onDrop={this.onDrop}>
          <ContentEditable textAreaClasses="box-content" refLink={createRandomNumber()} html={this.props.editor.html} onChange={this.onContentEditableChange} isTextSelected={this.isTextSelected} onTextSelect={this.onTextSelect} />
        </DropZone>
      </div>
    );
  }

});

export default Editor;