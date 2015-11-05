import React, { Component, PropTypes } from 'react';
import { Dialog, IconButton, FlatButton } from 'material-ui';

export default class CarouselEditor extends Component {

  constructor(props) {
    super(props);
    this.state = { images: props.initialImages }

    this.show = this.show.bind(this);
    this.dismiss = this.dismiss.bind(this);
    this.handleReorder = this.handleReorder.bind(this);
    this.handleImageUp = this.handleImageUp.bind(this);
    this.handleImageDown = this.handleImageDown.bind(this);
    this._swapIndexes = this._swapIndexes.bind(this);
  }

  show() {
    this.refs.dialog.show();
  }

  dismiss() {
    this.refs.dialog.dismiss();
  }

  handleReorder() {
    this.props.reorderCarousel(this.state.images);
    this.refs.dialog.dismiss();
  }

  handleImageUp(index) {
    if(index !== 0) {
      let images = this._swapIndexes(this.state.images.slice(), index, index-1);
      this.setState({ images: images });
    }
  }

  handleImageDown(index) {
    if(index !== this.state.images.length-1) {
      let images = this._swapIndexes(this.state.images.slice(), index, index+1);
      this.setState({ images: images });
    }
  }

  _swapIndexes(array, i, j) {
    let itemA;
    itemA = array[i];
    array[i] = array[j];
    array[j] = itemA;
    return array;
  }

  render() {
    const actions = [
      <FlatButton
      key={0}
      label="Cancel"
      style={{color: '#337ab7'}}
      onTouchTap={this.dismiss} />,
    <FlatButton
      key={1}
      label="Submit"
      style={{color: '#337ab7'}}
      onTouchTap={this.handleReorder } />
    ];

    let images = this.state.images.map((image, index) => {
      let imageTabStyle = {
        background: `url('${image.url}') center / cover no-repeat`
      };

      let fillerColor = index % 2 === 0 ? '#337ab7' : '#444';
      return (
        <div key={index} className="rce-image-container">
          <div className="rce-order">{index+1}</div>
          <div className="rce-image" style={imageTabStyle}></div>
          <div className="rce-controls">
            <IconButton iconStyle={{color: '#333'}} iconClassName="fa fa-arrow-up" tooltip="Move image up" onClick={this.handleImageUp.bind(this, index)} />
            <IconButton iconStyle={{color: '#333'}} iconClassName="fa fa-arrow-down" tooltip="Move image down" onClick={this.handleImageDown.bind(this, index)} />
          </div>
          <div style={{backgroundColor: fillerColor}} className="rce-filler"></div>
        </div>
      );
    });

    let body = (
      <div className="carousel-editor">
        {images}
      </div>
    );

    return (
      <Dialog ref="dialog"
              style={{zIndex: 1000}}
              actions={actions}
              modal={false}
              autoDetectWindowHeight={true}
              autoScrollBodyContent={true}>
              {body}
      </Dialog>
    );
  }
}

CarouselEditor.PropTypes = {
  initialImages: React.PropTypes.array,
  reorderCarousel: React.PropTypes.func.isRequired
};

CarouselEditor.defaultProps = {
  initialImages: []
};