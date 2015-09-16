import React from 'react';
import _ from 'lodash';
import rangy from 'rangy';
import Sanitize from 'sanitize-html';
import Utils from '../../utils/DOMUtils';
import Helpers from '../../utils/Helpers';
import ImageUtils from '../../utils/Images';
import Hashids from 'hashids';

const hashids = new Hashids('hackster', 4);

const ContentEditable = React.createClass({

  componentWillMount() {
    this.debouncedEmitChange = _.debounce(this.emitChange, 30);
    this.debouncedResize = _.debounce(this.handleResize, 30);
  },

  componentDidMount() {
    /** Updates the dom store; usually happens on initial load to get the html flowing through our parsers. */
    if(this.props.editor.dom.length < 1 && this.props.editor.html.length > 1) {
      this.emitChange();
    }

    /** Sets the initial cursor tracker on the first element. */
    if(this.props.editor.cursorPosition.node === null) {
      let firstChild = React.findDOMNode(this).firstChild;
      this.props.actions.setCursorPosition(0, firstChild, 0, firstChild);
    } else {
      this.setCursorOnUpdate();
    }

    /** Issues the Toolbars notice of the CE width on resize. */
    window.addEventListener('resize', this.debouncedResize);
  },

  componentWillUnmount() {
    window.removeEventListener('resize', this.debouncedResize);
  },

  componentWillReceiveProps(nextProps) {
    if(nextProps.editor.getLatestHTML === true) {
      this.emitChange();
      this.props.actions.getLatestHTML(false);
    }

    if(nextProps.editor.forceUpdate === true && this.props.editor.forceUpdate === false) {
      this.forceUpdate(function() {
        this.props.actions.forceUpdate(false);
      }.bind(this));
    }
  },

  componentWillUpdate() {
    /** Sets initial CEWidth for the Toolbars. */
    if(this.props.toolbar.CEWidth === null) {
      this.props.actions.setCEWidth(React.findDOMNode(this).offsetWidth);
    }
  },

  componentDidUpdate() {
    this.setCursorOnUpdate();
  },

  shouldComponentUpdate(){
    return false;
  },

  setCursorOnUpdate() {
    let rootNode = React.findDOMNode(this);
    let cursorPosition = this.props.editor.cursorPosition;
    let node = cursorPosition.node || rootNode.children[cursorPosition.pos];
    let nodeByHash = Utils.findBlockNodeByHash(node.getAttribute('data-hash'), rootNode, cursorPosition.pos);
    let el = (this.props.editor.setCursorToNextLine && nodeByHash.nextSibling !== undefined) ? nodeByHash.nextSibling : nodeByHash;

    if(el === undefined || el === null) {
      console.log('PROBLEMO! EL DOESNT EXIST!', nodeByHash, node, cursorPosition);
      return;
    }

    let { sel, range } = Utils.getSelectionData();
    let offset = this.props.editor.setCursorToNextLine ? 0 : cursorPosition.offset;
    let textNode = el.nodeName === 'DIV' && el.classList.contains('react-editor-carousel')
                 ? Utils.getTextNodeFromCarousel(el)
                 : el.nodeName === 'DIV' && el.classList.contains('react-editor-video')
                 ? Utils.getTextNodeFromVideo(el)
                 : Utils.getFirstTextNode(el);

    /** Makes sure its a text node. */
    if(textNode.nodeType !== 3 && textNode.nodeType === 1) {
      textNode = Utils.getLastTextNode(textNode);
    }

    /** Protects setStart from an index that was deleted. */
    if(textNode.textContent.length < offset) {
      offset = textNode.textContent.length;
    }

    range.setStart(textNode, offset);

    if(textNode.parentNode.nodeName === 'FIGCAPTION') {
      range.selectNodeContents(textNode);
    }

    // console.log('Setting Cursor To: ', cursorPosition.node, ' @: ' + offset, el, this.props.editor.setCursorToNextLine);

    rangy.getSelection().setSingleRange(range);
    this.props.actions.setCursorToNextLine(false);
  },

  trackCursor(e) {
    let { sel, range, parentNode, depth, startOffset, anchorNode } = Utils.getSelectionData();
    let CE = React.findDOMNode(this);
    let activeButtons = {
      'B': true,
      'STRONG': true,
      'I': true,
      'EM': true,
      'A': true
    };

    this.props.actions.setCursorPosition(depth, parentNode, startOffset, anchorNode);

    if(sel.rangeCount) {
      /** Makes sure there's always a P in CE. */
      if(CE.innerHTML.length < 1) {
        console.log('WTF HAPPEN!?', range, depth);
        this.createBlockElement('p', 0, false);
      }

      /** Cleans br tags in top level block elements. */
      Utils.removeBRTagsFromElement(CE);

      /** Recursively cleans up all br and empty tags. */
      if(e.keyCode === 8 && Utils.isImmediateChildOfContentEditable(parentNode, CE)
         && !parentNode.classList.contains('react-editor-carousel') && !parentNode.classList.contains('react-editor-video')) {
        Utils.removeEmptyTags(parentNode);
      }

      /** Cleans up UL tags. */
      if(e.keyCode === 8 && parentNode.nodeName === 'UL' && parentNode.childNodes.length < 1) {
        this.props.actions.transformBlockElement('p', depth, true);
        this.props.actions.forceUpdate(true);
      } else if(e.keyCode === 8 && range.startContainer.nodeName === 'LI' && range.startContainer.textContent.length < 1) {
        /** When a list item is being removed, this sets the cursor to the previous LI.  Saves us a forceUpdate render.*/
        range.selectNodeContents(parentNode.lastChild);
        range.collapse(false);
        sel.setSingleRange(range);
      }


      /** Handles Anchor PopOver. */
      if(anchorNode.parentNode && anchorNode.parentNode.nodeName === 'A') {
        this.handlePopOver(true);
      } else {
        this.handlePopOver(false);
      }
      /** Handles Image Popover. */
      if(parentNode.nodeName === 'DIV' && parentNode.classList.contains('react-editor-carousel') && range.startContainer.nodeName === 'DIV') {
        let node = range.startContainer.firstChild;
        this.props.actions.toggleImageToolbar(true, { node: parentNode, depth: depth, top: parentNode.offsetTop, height: node.offsetHeight, width: node.offsetWidth, left: node.offsetLeft, type: 'carousel' });
      } else if(parentNode.nodeName === 'DIV' && parentNode.classList.contains('react-editor-video') && range.startContainer.nodeName === 'DIV') {
        let node = range.startContainer.firstChild;
        this.props.actions.toggleImageToolbar(true, { node: parentNode, depth: depth, top: parentNode.offsetTop, height: node.offsetHeight, width: node.offsetWidth, left: node.offsetLeft, type: 'video' });
      } else {
        if(this.props.editor.showImageToolbar === true) {
          this.props.actions.toggleImageToolbar(false, {});
        }
      }
      /** Handles Active Button Toggling. */
      if(anchorNode.parentNode && activeButtons[anchorNode.parentNode.nodeName]) {
        let list = Utils.createListOfActiveElements(anchorNode, parentNode);
        this.props.actions.toggleActiveButtons(list);
      } else {
        this.props.actions.toggleActiveButtons([]);
      }

      /** Resets Caption on backspace. */
      if(anchorNode.nodeName === 'FIGCAPTION' && (e.keyCode === 8 || e.keyCode === 46)) {
        anchorNode.innerText = 'caption (optional)';
        range.selectNodeContents(anchorNode);
        rangy.getSelection().setSingleRange(range);
      }
    }
  },

  handlePopOver(shouldShow) {
    if(shouldShow) {
      let sel = rangy.getSelection();
      let range = sel.getRangeAt(0);
      let anchor = Utils.getAnchorNode(range.startContainer);

      if(!anchor) { return; }

      let props = {
        node: sel.anchorNode,
        range: range,
        href: anchor.getAttribute('href'),
        text: anchor.textContent,
        version: 'preview'
      };
      this.props.actions.showPopOver(true, props);
    } else {
      this.props.actions.showPopOver(false, {});
    }
  },

  onInput() {
    this.debouncedEmitChange();
  },

  emitChange(){
    let html = React.findDOMNode(this).innerHTML;
    /** Last resort to make sure theres always an element in the dom. */
    if(html.length < 1) {
      html = '<p></p>';
    }
    this.props.onChange(html);
  },

  handleResize() {
    this.props.actions.toggleImageToolbar(false, {});
    this.props.actions.setCEWidth(React.findDOMNode(this).offsetWidth);
  },

  preventEvent(e) {
    e.preventDefault();
    e.stopPropagation();
  },

  createBlockElement(type, depth, setCursorToNextLine) {
    let cursorPlacement = setCursorToNextLine === false ? false : true;
    this.props.actions.createBlockElement(type, depth, cursorPlacement);
    this.props.actions.forceUpdate(true);
  },

  delayedUpdate() {
    setTimeout(() => {
      this.props.actions.setCursorToNextLine(true);
      this.props.actions.forceUpdate(true);
    }, 100);
  },

  handleEnterKey(e) { 
    let { sel, range, parentNode, startOffset, depth, anchorNode } = Utils.getSelectionData(); 
    if(sel.rangeCount) {
      let hasTextAfterCursor = false;
      let cursorOffset = startOffset;
      let hash;

      /** If theres text after the cursor. */
      if((parentNode.textContent.indexOf(anchorNode.textContent) + startOffset) < parentNode.textContent.length) {
        hasTextAfterCursor = true;
      }

      switch(parentNode.nodeName) {
        case 'P':
          /**
           * Handles video parser when enter is pressed.
           */
          let url = Utils.getRootParentElement(anchorNode).textContent.trim();
          if(url.split(' ').length < 2 && Helpers.isUrlValid(url, ['youtube', 'vimeo', 'vine'])) {
            this.preventEvent(e);
            let videoData = Helpers.getVideoData(url);
            if(!videoData) { 
              // TODO: HANDLE VIDEO ERROR!
            } else {
              let metaList = document.getElementsByTagName('meta');
              let csrfToken = _.findWhere(metaList, {name: 'csrf-token'}).content;
              let projectId = window.location.href.match(/\/[\d]+/).join('').slice(1);
              let promise = ImageUtils.fetchImageAndTransform(videoData, projectId, csrfToken);

              promise.then(imageData => {
                this.props.actions.handleVideo(imageData, depth);
                this.props.actions.forceUpdate(true);
              }).catch(err => {
                console.log('Video Err: ' + err);
              });
            }
          } else if(hasTextAfterCursor) {
            this.delayedUpdate();
          } else {
            this.preventEvent(e);
            this.createBlockElement('p', depth);
            this.props.actions.forceUpdate(true);
          }
          break;

        case 'PRE':
          if(hasTextAfterCursor) {
            this.delayedUpdate();
          } else {
            this.preventEvent(e);
            this.createBlockElement('pre', depth, true);
          }
          break;

        case 'BLOCKQUOTE':
          if(hasTextAfterCursor) {
            this.delayedUpdate();
          } else {
            this.preventEvent(e);
            this.createBlockElement('p', depth, true);
          }
          break;

        case 'UL':
          if((anchorNode.nodeName === 'LI'|| Utils.getListItemFromTextNode(anchorNode).nodeName === 'LI') && anchorNode.textContent.length < 1) {
            this.preventEvent(e);
            let li = Utils.getListItemFromTextNode(anchorNode);
            this.props.actions.removeListItemFromList(depth, Utils.getListItemPositions(li, li, li.parentNode)[0]);
            this.createBlockElement('p', depth);
          }
          break;

        case 'DIV':
          if(parentNode.classList.contains('react-editor-carousel') || parentNode.classList.contains('react-editor-video')) {
            this.preventEvent(e);

            if(range.startContainer.nodeName === 'DIV') {
              this.props.actions.setCursorPosition(depth+1, parentNode, startOffset, anchorNode);
              this.createBlockElement('p', depth-1, false);
            } else {
              this.props.actions.setCursorPosition(depth, parentNode, startOffset, anchorNode);
              this.createBlockElement('p', depth);
            }
          }
          break;

        default:
          this.preventEvent(e);
          this.createBlockElement('p', depth);
          break;
      }
    }
  },

  handleBackspace(e) {
    let { sel, range, parentNode, depth, anchorNode } = Utils.getSelectionData();
    if(sel.rangeCount) {

      /** Maintains the first element as a P when user is deleting things. */
      if(depth === 0 && parentNode.textContent.length < 1 && React.findDOMNode(this).children.length < 2) {
        if(range.startContainer.nodeName !== 'FIGCAPTION') {
          this.preventEvent(e);
        }
      }

      /** Transorms a PRE or Blockquote to a P if its empty and the first element in CE. */
      if(depth === 0 && (parentNode.nodeName === 'PRE' || parentNode.nodeName === 'BLOCKQUOTE') && parentNode.textContent.length < 1) {
        this.preventEvent(e);
        this.props.actions.transformBlockElement('p', depth);
        this.props.actions.forceUpdate(true);
      }

      /** If user deleted the paragraph under a PRE, create a new one. */
      if(React.findDOMNode(this).lastChild.nodeName === 'PRE' && depth === React.findDOMNode(this).children.length) {
        this.createBlockElement('p', depth, false);
        this.props.actions.forceUpdate(true);
      }

      /** Prevents a Carousel being split apart from a delete event.  Normal op would suck the img into the current paragraph. */
      if(e.keyCode === 46 && parentNode.nextSibling && parentNode.nextSibling.nodeName === 'DIV' 
         && (parentNode.nextSibling.classList.contains('react-editor-carousel') || parentNode.nextSibling.classList.contains('react-editor-video'))
         && anchorNode.textContent.length === 0) {
        this.preventEvent(e);
        this.props.actions.removeBlockElements([{ depth: depth }]);
        this.props.actions.toggleImageToolbar(false, {});
      }
    }
  },

  handleMediaPermissions(e) {
    let { sel, range, anchorNode, parentNode, depth, startOffset } = Utils.getSelectionData();
    if(sel.rangeCount) {
      let prevSib = Utils.getBlockElementsPreviousSibling(parentNode, React.findDOMNode(this));
      let arrowKeys = {
        '37': true,
        '38': true,
        '39': true,
        '40': true
      };

      if(parentNode.nodeName === 'DIV' && parentNode.classList.contains('react-editor-carousel')
         || parentNode.nodeName === 'DIV' && parentNode.classList.contains('react-editor-video')) {

        /** Prevents any editing to the image wrapper div. */
        if(range.startContainer.nodeName === 'DIV' && (range.startContainer.classList.contains('react-editor-image-wrapper')
          || range.startContainer.classList.contains('react-editor-video-inner'))
          && !arrowKeys[e.keyCode.toString()]) {
          this.preventEvent(e);
        }

        if(range.startContainer.nodeName === 'BUTTON' && range.startContainer.classList.contains('reit-controls-button')) {
          this.preventEvent(e);
          this.props.actions.setCursorPosition(depth, parentNode, startOffset, anchorNode);
          this.props.actions.forceUpdate(true);
        }

        if(anchorNode.nodeType === 3 && anchorNode.parentNode.nodeName === 'FIGCAPTION') {
          range = rangy.getSelection().getRangeAt(0);
          /** Prevents backspace on figcaption from moving it up. */
          if(range.startOffset === 0 && range.endOffset === 0 && !arrowKeys[e.keyCode.toString()] && e.keyCode !== 32) {
            this.preventEvent(e);
          }
          /** Resets figcaption. */
          if(range.startContainer.textContent === 'caption (optional)' && e.keyCode !== 8 && !arrowKeys[e.keyCode.toString()]) {
            range.selectNodeContents(anchorNode);
            rangy.getSelection().setSingleRange(range);
          }
        }

        /** Prevents backspace when figcaption is empty. */
        if(anchorNode.nodeName === 'FIGCAPTION' && (e.keyCode === 8 || e.keyCode === 46)) {
          this.preventEvent(e);
        }
      }
    }
  },

  handleCarouselNavigation(node) {
    let carousel = Utils.getRootParentElement(node);
    let depth = Utils.findChildsDepthLevel(carousel, carousel.parentNode);
    let inner = carousel.firstChild;
    let figures = inner.children;
    let activeImage = _.find(figures, function(fig) {
      return fig.classList.contains('show');
    });
    let activeIndex = _.findIndex(figures, function(fig) {
      return fig.classList.contains('show');
    });

    if(figures.length > 1) {
      let left;
      activeImage.classList.remove('show');

      if(node.classList.contains('left')) {
        if(activeIndex === 0) {
          figures[figures.length-1].classList.add('show');
        } else {
          figures[activeIndex-1].classList.add('show');
        }
      } else {
        if(activeIndex === figures.length-1) {
          figures[0].classList.add('show');
        } else {
          figures[activeIndex+1].classList.add('show');
        }
      }
      this.props.actions.toggleImageToolbar(false, {});
      this.props.actions.updateImageToolbarData({ parent: carousel, depth: depth, top: carousel.offsetTop });
      this.props.actions.getLatestHTML(true);
    }
  },

  handleTab(e) {
    this.preventEvent(e);
    let sel = rangy.getSelection(),
        range = sel.rangeCount ? sel.getRangeAt(0) : null,
        tab = document.createTextNode('    ');
    if(range) {
      range.insertNode(tab);
      range.setEndAfter(tab);
      range.setStartAfter(tab);
      sel.setSingleRange(range)
    }
  },

  onKeyDown(e) {
    /** If user deleted the paragraph under a PRE */
    if(React.findDOMNode(this).lastChild.nodeName === 'PRE') {
      let { depth } = Utils.getSelectionData();
      this.createBlockElement('p', depth, false);
      this.props.actions.forceUpdate(true);
    }
    /** Removes any text with specified class.  Mimics a placeholder. */
    if(rangy.getSelection().anchorNode.parentNode.classList.contains('react-editor-placeholder-text')) {
      let target = rangy.getSelection().anchorNode.parentNode;
      target.classList.remove('react-editor-placeholder-text');
      target.textContent = '';
    }

    this.handleMediaPermissions(e);

    switch(e.keyCode || e.charCode) {
      case 13: // ENTER
        this.handleEnterKey(e);
        break;
      case 8: // BACKSPACE
      case 46: // DELETE
        this.handleBackspace(e);
        break;
      case 9: // TAB
        this.handleTab(e);
        break;
    default: 
      break;
    }
  },

  onKeyUp(e) {
    if(e.keyCode === undefined || e.type === 'mouseup') {
      this.preventEvent(e);
      let node = React.findDOMNode(e.target);
      let { sel, range } = Utils.getSelectionData();
      let caretRange = Utils.getMouseEventCaretRange(e);

      /** Handles cursor placement. */
      if(node !== React.findDOMNode(this) && (range.startOffset < caretRange.startOffset && range.endOffset !== caretRange.endOffset) 
         || (range.endOffset > caretRange.endOffset && range.startOffset !== caretRange.startOffset)) {
        sel.setSingleRange(caretRange);
      }

    } else {
      this.trackCursor(e);
    }
  },

  onMouseOver(e) {
    let node = React.findDOMNode(e.target),
        parent = Utils.getRootParentElement(node), 
        depth = Utils.findChildsDepthLevel(parent, parent.parentNode);

    if(node.nodeName === 'IMG' && parent.classList.contains('react-editor-carousel') && this.props.editor.showImageToolbar === false) {
      this.props.actions.toggleImageToolbar(true, { node: parent, depth: depth , top: parent.offsetTop, height: node.offsetHeight, width: node.offsetWidth, left: node.offsetLeft, type: 'carousel' });
    }

    if(node.nodeName === 'IMG' && parent.classList.contains('react-editor-video') && this.props.editor.showImageToolbar === false) {
      this.props.actions.toggleImageToolbar(true, { node: parent, depth: depth , top: parent.offsetTop, height: node.offsetHeight, width: node.offsetWidth, left: node.offsetLeft, type: 'video' });
    }
  },

  onClick(e) {
    this.preventEvent(e);
    let node = React.findDOMNode(e.target);

    if(node.nodeName === 'BUTTON' && node.classList && node.classList.contains('reit-controls-button')) {
      this.handleCarouselNavigation(node);
    }
  },

  handlePaste(e) {
    this.preventEvent(e);
    let pastedText;

    if(window.clipboardData && window.clipboardData.getData) {  // IE
      pastedText = window.clipboardData.getData('Text');
    } else if(e.clipboardData && e.clipboardData.getData) {
      if(e.clipboardData.types.indexOf('text/html') === 1) {
        pastedText = e.clipboardData.getData('text/html');
      } else {
        pastedText = e.clipboardData.getData('text/plain');
      }
    }

    let clean = this.handleOnPasteSanitization(pastedText); 
  
    e.target.innerHTML += clean;
    Utils.setCursorByNode(React.findDOMNode(e.target));
    this.emitChange();
  },

  handleOnPasteSanitization(dirty) {
    return Sanitize(dirty, {
      allowedTags: [ 'p', 'div', 'a', 'ul', 'ol', 'li', 'b', 'i', 'blockquote', 'pre', 'code', 'strong', 'em' ],
      allowedAttributes: {
        'a': [ 'href' ]
      },
      allowedSchemes: [ 'data', 'http', 'https' ],
      transformTags: {
        'br': function(tagType, attribs) {
          return {
            tagType: 'span',
            attribs: attribs
          };
        },
        'ol': 'ul'
      },
      exclusiveFilter: function(frame) {
        if(frame.tag === 'a' || frame.tag === 'img' && Object.keys(frame.attribs).length > 0) {
          return true;
        } else {
          return !frame.text.trim();
        }
      }
    });
  },

  render() {
    return (
      <div
        ref="contentEditable"
        className="no-outline-focus content-editable"
        style={this.props.style || null}
        onInput={this.onInput}
        onKeyDown={this.onKeyDown}
        onKeyUp={this.onKeyUp}
        onMouseUp={this.onKeyUp}
        onMouseOver={this.onMouseOver}
        onClick={this.onClick}
        onPaste={this.handlePaste}
        contentEditable={true}
        dangerouslySetInnerHTML={{__html: this.props.html}}></div>
    );
  }
});

export default ContentEditable;