import React from 'react';
import ReactDOM from 'react-dom';
import Utils from '../utils/DOMUtils';
import _ from 'lodash';
import FigCaption from './FigCaption';
import ImageToolbar from './ImageToolbar';
import WidgetPlaceholder from './WidgetPlaceholder';

const Video = React.createClass({

  getInitialState() {
    return {
      height: '100%'
    }
  },

  componentWillMount() {
    this.calculateHeight = _.debounce(this.handleResize, 30);
    window.addEventListener('resize', this.calculateHeight);
  },

  componentWillUnmount() {
    window.removeEventListener('resize', this.calculateHeight);
  },

  componentDidMount() {
    this.handleResize();
  },

  shouldComponentUpdate(nextProps, nextState) {
    return nextProps.videoData !== this.props.videoData ||
           nextState.height !== this.state.height ||
           nextProps.editor.imageToolbarData.storeIndex === this.props.storeIndex ||
           nextProps.editor.updateComponent === this.props.storeIndex;
  },

  handleResize() {
    let width = ReactDOM.findDOMNode(this.refs.iframe).offsetWidth;

    this.setState({
      height: (width * (9/16))
    });
  },

  handleUnsavedChanges() {
    if(this.props.editor.hasUnsavedChanges === false) {
      this.props.actions.hasUnsavedChanges(true);
    }
  },

  handleKeyDown(e) {
    let currentNode = ReactDOM.findDOMNode(this);
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
    if(e.keyCode === 13 && ReactDOM.findDOMNode(e.target).nodeName !== 'FIGCAPTION') {
      e.preventDefault();
      this.props.actions.prependCE(this.props.storeIndex);
    }

    /** On Backspace */
    if(e.keyCode === 8 || e.keyCode === 46) {
      if(ReactDOM.findDOMNode(e.target).nodeName !== 'FIGCAPTION') {
        e.preventDefault();
      }
    }
  },

  handleFigCaptionKeys(e, key) {
    if(key === 'Enter') {
      e.preventDefault();

      let Editable = Utils.getParentOfCE(ReactDOM.findDOMNode(this));
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
    this.handleUnsavedChanges();
  },

  handleMouseOver(e) {
    let target = ReactDOM.findDOMNode(e.target),
        currentNode = ReactDOM.findDOMNode(this),
        parent = Utils.getRootParentElement(currentNode),
        depth = Utils.findChildsDepthLevel(parent, parent.parentNode);

    if(this.props.editor.showImageToolbar && this.props.editor.imageToolbarData.node !== ReactDOM.findDOMNode(this)) {
      this.props.actions.toggleImageToolbar(false, {});
      this.props.actions.updateComponent(this.props.editor.imageToolbarData.storeIndex);
    }

    if(( target.nodeName === 'IFRAME' && target.classList.contains('react-editor-iframe') ) ||
       ( target.nodeName === 'DIV' && target.classList.contains('react-editor-image-wrapper') ) ||
       ( target.nodeName === 'VIDEO' && target.classList.contains('react-editor-iframe') ) ||
       ( target.nodeName === 'IMG' && target.classList.contains('react-editor-iframe') )) {
      this.props.actions.toggleImageToolbar(true, {
        node: currentNode,
        depth: depth,
        top: currentNode.offsetTop,
        height: currentNode.offsetHeight,
        width: currentNode.offsetWidth,
        left: currentNode.offsetLeft,
        storeIndex: this.props.storeIndex,
        type: 'video'
      });
    }
  },

  render: function() {
    let data = this.props.videoData[0];
    let imageToolbar = this.props.editor.showImageToolbar && this.props.editor.imageToolbarData.storeIndex === this.props.storeIndex
                     ? (<ImageToolbar editor={this.props.editor} actions={this.props.actions} />)
                     : (null);

    let video;
    /** mp4 and image are for URLWidgets. */
    if(data.service === 'mp4') {
      video = (<video style={{ height: this.state.height }} ref="iframe" className="react-editor-iframe" preload="metadata" controls="controls">
                <source type="video/mp4" src={data.embed} />
                <a href={data.embed} alt={data.alt}>{data.embed}</a>
               </video>);
    } else if(data.type === 'image') {
      video = (<img style={{ height: this.state.height }} ref="iframe" className="react-editor-iframe" src={data.embed} />);
    } else {
      video = (<iframe style={{ height: this.state.height }} ref="iframe" className="react-editor-iframe" src={data.embed} alt={data.alt} frameBorder="0"></iframe>);
    }

    return (
      <div className="react-editor-video"
           data-hash={this.props.hash}
           data-video-id={data.id}
           onFocus={this.handleFocus}
           onKeyDown={this.handleKeyDown}
           onMouseOver={this.handleMouseOver}
           tabIndex={0}>
        <div className="react-editor-video-inner">
          <figure className="react-editor-figure" data-type="video">
            <div style={{ height: this.state.height }} className="react-editor-image-wrapper">
              {video}
              <FigCaption className="react-editor-figcaption"
                          style={{ width:data.width }}
                          handleFigCaptionKeys={this.handleFigCaptionKeys}
                          setFigCaptionText={this.handleFigCaptionText.bind(this, 0)}
                          html={data.figcaption || 'caption (optional)'}
                          actions={this.props.actions}
                          isIE={this.props.editor.isIE} />
            </div>
          </figure>
        </div>
        {imageToolbar}
      </div>
    );
  }

});

export default Video;