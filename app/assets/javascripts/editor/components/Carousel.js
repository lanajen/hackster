import React from 'react';
import Utils from '../utils/DOMUtils';
import _ from 'lodash';
import FigCaption from './FigCaption';
import ImageToolbar from './ImageToolbar';

import Hashids from 'hashids';

const hashids = new Hashids('hackster', 4);

const Carousel = React.createClass({

  handleKeyDown(e) {
    let currentNode = React.findDOMNode(this);
    let Editable = Utils.getParentOfCE(currentNode);
    let nodeToFocus, CE, lastChild, firstChild;

    /** Arrow up into CE or focus the previous media block. */
    if(e.keyCode === 38 && this.props.storeIndex > 0) {
      e.preventDefault();
      currentNode.blur();
      nodeToFocus = Editable.children[this.props.storeIndex-1];

      if(nodeToFocus.classList.contains('dropzone')) {
        CE = nodeToFocus.children[1];
        lastChild = CE.lastChild;
        this.props.actions.setCursorPosition(CE.children.length, lastChild, lastChild.textContent.length, Utils.getLastTextNode(lastChild), CE.getAttribute('data-hash'));
        this.props.actions.forceUpdate(true);
      } else {
        nodeToFocus.focus();
      }
    }
    /** Arrow down into CE or focus the previous media block. */
    if(e.keyCode === 40 && this.props.storeIndex < Editable.children.length) {
      e.preventDefault();
      currentNode.blur();
      nodeToFocus = Editable.children[this.props.storeIndex+1];
      if(nodeToFocus.classList.contains('dropzone')) {
        CE = nodeToFocus.children[1];
        firstChild = CE.firstChild;
        this.props.actions.setCursorPosition(0, firstChild, 0, Utils.getFirstTextNode(firstChild), CE.getAttribute('data-hash'));
        this.props.actions.forceUpdate(true);
      } else {
        nodeToFocus.focus();
      }
    }
    /** On Enter Key */
    if(e.keyCode === 13 && React.findDOMNode(e.target).nodeName !== 'FIGCAPTION') {
      e.preventDefault();
      //this.props.actions.prependCE(this.props.storeIndex);
    }

    /** On Backspace */
    if(e.keyCode === 8 || e.keyCode === 46) {
      if(React.findDOMNode(e.target).nodeName !== 'FIGCAPTION') {
        e.preventDefault();
      }
    }
  },

  handleNavigation(direction, e) {
    e.preventDefault();
    let inner = React.findDOMNode(this.refs.inner);
    let figures = inner.children;
    let activeIndex = _.findIndex(figures, function(fig) {
      return fig.classList.contains('show');
    });

    this.props.actions.updateShownImage(activeIndex, this.props.storeIndex, direction);
    this.props.actions.toggleImageToolbar(false, {});
  },

  handleFigCaptionKeys(e, key) {
    if(key === 'Enter') {
      e.preventDefault();

      let Editable = Utils.getParentOfCE(React.findDOMNode(this));
      let nodeToFocus, CE, lastChild, firstChild;

      this.props.actions.toggleImageToolbar(false, {});

      nodeToFocus = Editable.children[this.props.storeIndex+1];
      if(nodeToFocus.classList.contains('dropzone')) {
        CE = nodeToFocus.children[1];
        firstChild = CE.firstChild;
        this.props.actions.setCursorPosition(0, firstChild, 0, Utils.getFirstTextNode(firstChild), CE.getAttribute('data-hash'));
        this.props.actions.forceUpdate(true);
      } else {
        nodeToFocus.focus();
      }
    }
  },

  handleFigCaptionText(figureIndex, html) {
    this.props.actions.setFigCaptionText(figureIndex, this.props.storeIndex, html);
  },

  handleMouseOver(e) {
    let target = React.findDOMNode(e.target),
        currentNode = React.findDOMNode(this),
        parent = Utils.getRootParentElement(currentNode), 
        depth = Utils.findChildsDepthLevel(parent, parent.parentNode);

    if(this.props.editor.showImageToolbar && this.props.editor.imageToolbarData.node !== React.findDOMNode(this)) {
      this.props.actions.toggleImageToolbar(false, {});
    }

    if((target.nodeName === 'IMG' && target.classList.contains('react-editor-image'))
       || (target.nodeName === 'DIV' && target.classList.contains('react-editor-image-wrapper')) 
        && this.props.editor.showImageToolbar === false) {
      this.props.actions.toggleImageToolbar(true, {
        node: currentNode,
        depth: depth,
        top: currentNode.offsetTop,
        height: currentNode.offsetHeight,
        width: currentNode.offsetWidth,
        left: currentNode.offsetLeft,
        storeIndex: this.props.storeIndex, 
        type: 'carousel' 
      });
    }
  },

  render() {
    let figures = this.props.images.map((image, index) => {
      let className = image.show ? 'react-editor-figure show' : 'react-editor-figure';
      return (
        <figure key={index} className={className} data-type="image">
          <div className="react-editor-image-wrapper">
            <img className="react-editor-image" src={image.url} alt={image.name} />
            <FigCaption className="react-editor-figcaption"
                        handleFigCaptionKeys={this.handleFigCaptionKeys}
                        setFigCaptionText={this.handleFigCaptionText.bind(this, index)}
                        html={image.figcaption || 'caption (optional)'}
                        actions={this.props.actions}
                        isIE={this.props.editor.isIE} />
          </div>
        </figure>
      );
    });

    let controls = figures.length > 1 
                 ? (<div className="reit-controls">
                      <button className="reit-controls-button left fa fa-chevron-left fa-2x" onClick={this.handleNavigation.bind(this, 'left')}></button>
                      <button className="reit-controls-button right fa fa-chevron-right fa-2x" onClick={this.handleNavigation.bind(this, 'right')}></button>
                    </div>)
                 : (null);

    let imageToolbar = this.props.editor.showImageToolbar && this.props.editor.imageToolbarData.node.getAttribute('data-hash') === this.props.hash
                     ? (<ImageToolbar editor={this.props.editor} actions={this.props.actions} />)
                     : (null);

    return (
      <div className="react-editor-carousel" 
           data-hash={this.props.hash}
           onKeyDown={this.handleKeyDown}
           onMouseOver={this.handleMouseOver}
           tabIndex={0}>
        <div className="react-editor-carousel-inner" ref="inner">
          {figures}
        </div>
        {controls}
        {imageToolbar}
      </div>
    );
  }

});

export default Carousel;