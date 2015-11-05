import React, { Component, PropTypes } from 'react';
import { Dialog, IconButton, FlatButton } from 'material-ui';

export default class CarouselEditor extends Component {

  constructor(props) {
    super(props);
    this.state = { images: props.initialImages, indexToAnimate: null }

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
      this.setState({ images: images, indexToAnimate: index-1 });

      setTimeout(() => { this.setState({ indexToAnimate: null }); }, 1000);
    }
  }

  handleImageDown(index) {
    if(index !== this.state.images.length-1) {
      let images = this._swapIndexes(this.state.images.slice(), index, index+1);
      this.setState({ images: images, indexToAnimate: index+1 });

      setTimeout(() => { this.setState({ indexToAnimate: null }); }, 1000);
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
      style={{backgroundColor: '#337ab7', color: 'white', marginRight: 10, borderRadius: 4}}
      onTouchTap={this.dismiss} />,
    <FlatButton
      key={1}
      label="Submit"
      style={{backgroundColor: '#337ab7', color: 'white', marginRight: 24, borderRadius: 4}}
      onTouchTap={this.handleReorder } />
    ];

    let images = this.state.images.map((image, index) => {
      let imageTabStyle = {
        background: `url('${image.url}') center / contain no-repeat`
      };

      let fillerColor = index % 2 === 0 ? '#337ab7' : '#444';

      let animateStyle = this.state.indexToAnimate == index ? { boxShadow: "1px 1px 12px rgba(0, 0, 0, 0.70), 3px 3px 12px rgba(0, 0, 0, 0.36)" } : {};

      return (
        <div key={index} style={animateStyle} className="rce-image-container">
          <div className="rce-order">{index+1}</div>
          <div className="rce-image-wrapper">
            <div className="rce-image" style={imageTabStyle}></div>
          </div>
          <div className="rce-controls">
            <IconButton iconStyle={{color: '#333'}} iconClassName="fa fa-arrow-up" tooltip="Move image up" onClick={this.handleImageUp.bind(this, index)} />
            <IconButton iconStyle={{color: '#333'}} iconClassName="fa fa-arrow-down" tooltip="Move image down" onClick={this.handleImageDown.bind(this, index)} />
          </div>
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
              style={{zIndex: 1000, overflow: 'auto'}}
              contentStyle={{width: '40%', minWidth: 400}}
              actions={actions}
              modal={false}
              autoScrollBodyContent={false}>
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