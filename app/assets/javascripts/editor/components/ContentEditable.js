import React from 'react';
import ReactDOM from 'react-dom';
import _ from 'lodash';
import rangy from 'rangy';
import Validator from 'validator';
import Utils from '../utils/DOMUtils';
import Parser from '../utils/Parser';
import Helpers from '../../utils/Helpers';
import ImageUtils from '../../utils/Images';
import Request from '../utils/Requests';
import { BlockElements } from '../utils/Constants';
import Hashids from 'hashids';
import { domWalk } from '../utils/Traversal';

const hashids = new Hashids('hackster', 4);

const ContentEditable = React.createClass({

  componentWillMount() {
    this.debouncedEmitChange = _.debounce(this.emitChange, 0);
    this.domObserver = new MutationObserver(this.handleDomMutation);
  },

  componentDidMount() {
    /** Sets the cursor to specific CE. */
    if(this.props.editor.cursorPosition.rootHash === this.props.hash) {
      this.setCursorOnUpdate();
    }

    /** Inits Mutation Observer. */
    this.domObserver.observe(ReactDOM.findDOMNode(this), {
      attributes: true,
      childList: true,
      characterData: true
    });
  },

  componentWillUnmount() {
    this.domObserver.disconnect();
  },

  componentWillReceiveProps(nextProps) {
    if(nextProps.editor.getLatestHTML === true) {
      this.emitChange();
      this.props.actions.getLatestHTML(false);
    }

    if(nextProps.editor.forceUpdate === true && nextProps.editor.currentStoreIndex === this.props.storeIndex) {
      this.forceUpdate(function() {
        this.setCursorOnUpdate();
        this.props.actions.forceUpdate(false);
      }.bind(this));
    } else if(nextProps.editor.forceUpdate === true && this.props.html !== nextProps.html) {
      this.forceUpdate(function() {
        this.setCursorOnUpdate();
        this.props.actions.forceUpdate(false);
      }.bind(this));
    }
  },

  componentDidUpdate() {
    /** Cleans up the top tree of this CE. */
    Utils.maintainImmediateChildren(ReactDOM.findDOMNode(this));

    if(this.props.html !== ReactDOM.findDOMNode(this).innerHTML.replace(/<br>/g, '<br/>')) {
      ReactDOM.findDOMNode(this).innerHTML = this.props.html;
    }
  },

  shouldComponentUpdate(){
    return false;
  },

  handleDomMutation(mutations) {
    let nodes;
    const blockEls = BlockElements;
    /** Shallow pass on immediate children of CE.  Makes sure no funny biz happens to our tree.
      * The observer is mainly for people tinkering with devtools html and perhaps an initial parse / paste action.
      * We handle deeper children in parseTree in Editable.js.  Why?
      * Mainly to prevent heavy recursive checks on each node on each dom mutation, which happens on every render on the whole tree.
     */
    mutations.forEach(mutation => {
      nodes = [].slice.apply(mutation.addedNodes);
      nodes.forEach(node => {

        let parentNode = Utils.getRootParentElement(node);
        if(parentNode !== null && !blockEls[parentNode.nodeName]) {

          if(node.parentNode !== null) {
            // node.parentNode.removeChild(node);
          }
        }

        /** Quick sweep on UL children.  Makes sure they're list items. */
        if(node.nodeName === 'UL') {
          let children = [].slice.apply(node.childNodes);
          children.forEach(child => {
            /** The regexp looks for a single instance of carriage return or whitespace. */
            if(child.nodeName !== 'LI' && child.textContent.length > 0 && child.textContent.match(/^[\u21B5|\s+]{1}$/) === null) {
              let li = document.createElement('li');
              li.textContent = child.textContent;
              // node.replaceChild(li, child);
            } else if(child.nodeName !== 'LI' && (child.textContent.match(/^[\u21B5|\s+]{1}$/) !== null || child.textContent.length < 1)) {
              // node.removeChild(child);
            }
          });
        }
      });
    });
  },

  setCursorOnUpdate() {
    /** Don't do any operations if the cursor is not in this CE. */
    if(this.props.editor.cursorPosition.rootHash !== this.props.hash) { return; }
    const cursorPosition = this.props.editor.cursorPosition;
    ReactDOM.findDOMNode(this).focus();

    let dataHash = Utils.getHashFromNode(cursorPosition.node);
    let liveNode = document.querySelector(`[data-hash="${dataHash}"]`);
    liveNode = liveNode ? liveNode : document.querySelector(`[data-hash="${cursorPosition.rootHash}"]`).firstChild;

    let el = (this.props.editor.setCursorToNextLine && liveNode && liveNode.nextSibling !== null) ? liveNode.nextSibling : liveNode;
    if(el === undefined || el === null) { return; }

    /** If we're moving to a new line, set the cursor at index 0. */
    let offset = this.props.editor.setCursorToNextLine ? 0 : cursorPosition.offset+1;
    let textNode = Utils.getLiveNode(el, cursorPosition.anchorNode);

    textNode = textNode === null ? Utils.getFirstTextNode(el) : textNode;
    /** Protects setStart from an index that was deleted. */
    if(textNode.textContent.length < offset) {
      offset = textNode.textContent.length;
    }
    this.setCursorAt(textNode, offset);
    this.props.actions.setCurrentStoreIndex(this.props.storeIndex);
    this.props.actions.setCursorToNextLine(false);
  },

  setCursorAt(node, offset) {
    let range = rangy.createRange();
    let sel = rangy.getSelection();
    range.setStart(node, offset);
    range.collapse(false);
    sel.setSingleRange(range);
  },

  trackCursor(e) {
    let { sel, range, parentNode, depth, startOffset, anchorNode } = Utils.getSelectionData();
    let CE = ReactDOM.findDOMNode(this);
    let activeButtons = {
      'B': true,
      'STRONG': true,
      'I': true,
      'EM': true,
      'A': true
    };

    this.props.actions.setCursorPosition(depth, parentNode, startOffset, anchorNode, CE.getAttribute('data-hash'));

    if(sel && sel.rangeCount) {
      /** Makes sure there's always a P in CE. */
      if(CE.innerHTML.length < 1) {
        this.createBlockElement('p', 0, false, this.props.storeIndex);
      }

      /**
        * Makes sure immediate children are block elements with a hash.
        * Removes br tags in immediate children.
        */
      Utils.maintainImmediateChildren(CE);
      this.emitChange();

      /** We tranformed BR's to spans for Edge, empty spans get cleaned up, Chrome needs a BR placement. #Edge Bug1 */
      if(e.keyCode === 8 && BlockElements[parentNode.nodeName] && parentNode.textContent.length < 1 && parentNode.children.length < 1) {
        parentNode.appendChild(document.createElement('br'));
      }

      /** On Enter; Cleans up browser adds on specific line. */
      if(e.keyCode === 13 && parentNode.previousSibling && parentNode.nodeName !== 'UL') {
        Utils.maintainImmediateNode(parentNode.previousSibling);
        this.emitChange();
      }

      /** Cleans up UL tags. */
      if(e.keyCode === 8 && parentNode.nodeName === 'UL' && parentNode.children.length === 1 && parentNode.children[0].textContent < 1) {
        this.props.actions.transformBlockElement('p', depth, true, this.props.storeIndex);
        this.props.actions.forceUpdate(true);
      }

      /** Handles Anchor PopOver. */
      if(Utils.isSelectionInAnchor(anchorNode)) {
        this.handlePopOver(true);
      } else {
        this.handlePopOver(false);
      }

      /** Handles Active Button Toggling. */
      if(anchorNode.parentNode && activeButtons[anchorNode.parentNode.nodeName]) {
        let list = Utils.createListOfActiveElements(anchorNode, parentNode);
        this.props.actions.toggleActiveButtons(list);
      } else {
        this.props.actions.toggleActiveButtons([]);
      }
    }
  },

  handlePopOver(shouldShow) {
    if(shouldShow) {
      let sel = window.getSelection();
      let range = sel.getRangeAt(0);
      let anchor = Utils.getAnchorNode(range.startContainer);
      if(!anchor) { return; }

      let props = {
        node: sel.anchorNode,
        parentNode: document.querySelector('.box'),
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

  onInput(e) {
    this.debouncedEmitChange();
  },

  emitChange(){
    let CE = ReactDOM.findDOMNode(this);
    let html = CE.innerHTML;
    let dataHash = CE.getAttribute('data-hash');
    let { depth, parentNode, startOffset, anchorNode } = Utils.getSelectionData();
    let cursorData = { pos: depth, node: parentNode, offset: startOffset, anchorNode: anchorNode, rootHash: dataHash };

    this.props.onChange(html, depth, this.props.storeIndex, cursorData);
  },

  preventEvent(e) {
    e.preventDefault();
    e.stopPropagation();
  },

  createBlockElement(type, depth, setCursorToNextLine, storeIndex) {
    let cursorPlacement = setCursorToNextLine === false ? false : true;
    this.props.actions.createBlockElement(type, depth, cursorPlacement, storeIndex);
    this.props.actions.forceUpdate(true);
  },

  createBlockElementWithChildren(parentNode, range, tag, depth, setCursorToNextLine, storeIndex) {

    range.setEndAfter(parentNode.lastChild);
    let contents = range.toHtml();
    range.deleteContents();
    /** If theres no text left over, just set the innerHtml to a br so we dont have to worry about left over inline tags. */
    let lastHtml = !parentNode.textContent.length ? '<br/>' : parentNode.innerHTML;
    let htmlToAppend = Parser.parseDOM(contents);
    let htmlToKeep = Parser.parseDOM(lastHtml);

    Promise.all([htmlToKeep, htmlToAppend])
      .then(results => {
        let children = {
          htmlToKeep: results[0],
          htmlToAppend: results[1]
        };
        this.props.actions.createBlockElementWithChildren(children, tag, depth, setCursorToNextLine, storeIndex);
        this.props.actions.forceUpdate(true);
      })
      .catch(err => { console.log('createBlockElementWithChildren Error', err); });
  },

  handleEnterKey(e) {
    let { sel, range, parentNode, startOffset, depth, anchorNode } = Utils.getSelectionData();

    if(sel.rangeCount) {
      let hasTextAfterCursor = false;
      let cursorOffset = startOffset;
      let CE = ReactDOM.findDOMNode(this);
      let hash;

      /** If theres text after the cursor. */
      if(parentNode.textContent && (parentNode.textContent.indexOf(anchorNode.textContent) + startOffset) < parentNode.textContent.length) {
        hasTextAfterCursor = true;
      }

      switch(parentNode.nodeName) {
        case 'P':
          this.preventEvent(e);

          /** Removes placeholder.  This is for when Enter is pressed only.  The other keys are handled in keydown. */
          if(parentNode.classList.contains('react-editor-placeholder-text')) {
            parentNode.classList.remove('react-editor-placeholder-text');
            parentNode.textContent = '';
            parentNode.appendChild(document.createElement('br'));
            this.emitChange();
          }

          /**
           * Handles video parser when enter is pressed.
           */
          let url = parentNode.textContent.trim();
          let text = range.startContainer.textContent.substring(0, range.startOffset).split(' ');

          if(Helpers.isTwitterUrlValid(url)) {
            let id = Helpers.getTwitterIdFromUrl(url);
            this.props.actions.createMediaByType({ id: id, embed: url, type: 'twitter', widgetType: 'twitter' }, depth, this.props.storeIndex, 'WidgetPlaceholder');
            this.props.actions.forceUpdate(true);
            return;
          }

          if(!Helpers.isUrlValid(text[text.length-1], 'video') && Utils.hasValidUrl(text[text.length-1]) && !Utils.isSelectionInAnchor(range.startContainer)) {
            Utils.transformTextToAnchorTag(sel, range, true);
            this.emitChange();
            setTimeout(() => {
              if(hasTextAfterCursor) {
                this.createBlockElementWithChildren(parentNode, range, 'p', depth, true, this.props.storeIndex);
              } else {
                this.createBlockElement('p', depth, true, this.props.storeIndex);
              }
              return;
            }, 50);
          }

          if(url.split(' ').length < 2 && Helpers.isUrlValid(url, 'video')) {
            let videoData = Helpers.getVideoData(url);
            if(!videoData) {
              // TODO: HANDLE VIDEO ERROR!
            } else {
              this.props.actions.createMediaByType([videoData], depth, this.props.storeIndex, 'Video');
              this.props.actions.forceUpdate(true);
            }
          } else if(hasTextAfterCursor) {
            this.createBlockElementWithChildren(parentNode, range, 'p', depth, true, this.props.storeIndex);
          } else {
            this.createBlockElement('p', depth, true, this.props.storeIndex);
          }
          break;

        case 'PRE':
          this.preventEvent(e);

          if(hasTextAfterCursor) {
            this.createBlockElementWithChildren(parentNode, range, 'pre', depth, true, this.props.storeIndex);
          } else {
            this.createBlockElement('pre', depth, true, this.props.storeIndex);
          }
          break;

        case 'H3':
          this.preventEvent(e);

          if(hasTextAfterCursor) {
            this.createBlockElementWithChildren(parentNode, range, 'h3', depth, true, this.props.storeIndex);
          } else {
            this.createBlockElement('p', depth, true, this.props.storeIndex);
          }
          break;

        case 'BLOCKQUOTE':
          this.preventEvent(e);

          if(hasTextAfterCursor) {
            this.createBlockElementWithChildren(parentNode, range, 'blockquote', depth, true, this.props.storeIndex);
          } else {
            this.createBlockElement('p', depth, true, this.props.storeIndex);
          }
          break;

        case 'UL':
          let li = Utils.getListItemFromTextNode(anchorNode);
          if((anchorNode.nodeName === 'LI'|| li.nodeName === 'LI') && li.textContent.length < 1) {
            this.preventEvent(e);
            this.props.actions.removeListItemFromList(depth, Utils.getListItemPositions(li, li, li.parentNode)[0], this.props.storeIndex);
            this.createBlockElement('p', depth, true, this.props.storeIndex);
          }
          break;

        case 'DIV':
          if(parentNode.classList.contains('react-editor-carousel') || parentNode.classList.contains('react-editor-video')) {
            this.preventEvent(e);

            if(range.startContainer.nodeName === 'DIV') {
              this.props.actions.setCursorPosition(depth+1, parentNode, startOffset, anchorNode, CE.getAttribute('data-hash'));
              this.createBlockElement('p', depth-1, false, this.props.storeIndex);
            } else {
              this.props.actions.setCursorPosition(depth, parentNode, startOffset, anchorNode, CE.getAttribute('data-hash'));
              this.createBlockElement('p', depth, true, this.props.storeIndex);
            }
          }
          break;

        default:
          this.preventEvent(e);
          this.createBlockElement('p', depth, true, this.props.storeIndex);
          break;
      }
    }
  },

  handleBackspace(e) {
    let { sel, range, parentNode, depth, anchorNode } = Utils.getSelectionData();
    let CE = ReactDOM.findDOMNode(this);
    if(sel.rangeCount) {

      /** Remove CE unless its the first or last. */
      if(depth <= 1 && this.props.storeIndex !== this.props.editor.dom.length-1
         && this.props.storeIndex !== 0 && CE.textContent.length < 1) {
         this.preventEvent(e);
         this.props.actions.deleteComponent(this.props.storeIndex);
      }

      /** Maintains the first & last element as a P when user is deleting things. */
      if((this.props.storeIndex === 0 || this.props.storeIndex === this.props.editor.dom.length-1)
               && depth === 0 && parentNode.textContent.length < 1 && CE.children.length < 2) {
        this.preventEvent(e);
      }

      /** Transorms a PRE or Blockquote to a P if its empty and the first element in CE. */
      if(depth === 0 && (parentNode.nodeName === 'PRE' || parentNode.nodeName === 'BLOCKQUOTE') && parentNode.textContent.length < 1) {
        this.preventEvent(e);
        this.props.actions.transformBlockElement('p', depth, false, this.props.storeIndex);
        this.props.actions.forceUpdate(true);
      }
    }
  },

  handleTab(e) {
    this.preventEvent(e);
    let sel = rangy.getSelection(),
        range = sel.rangeCount ? sel.getRangeAt(0) : null,
        tab = document.createTextNode('    ');
    if(range) {
      range.insertNode(tab);
      range.setStartAfter(tab);
      sel.setSingleRange(range)
    }
  },

  handleArrowKeys(e) {
    let { depth, parentNode, anchorNode } = Utils.getSelectionData();
    let CE = ReactDOM.findDOMNode(this);

    /** Cursor is in a CE and moving up to a media element. */
    if(e.keyCode === 38 && depth === 0 && this.props.storeIndex > 0) {
      /** If the cursor is in a UL, let the user navigate through the list except if the cursor is the first list item. */
      if(parentNode.nodeName === 'UL' && Utils.getListItemFromTextNode(anchorNode) !== parentNode.firstChild) {
        return;
      }
      let Editable = Utils.getParentOfCE(CE);
      let nodeToFocus = Editable.children[this.props.storeIndex-1];
      nodeToFocus.focus();
    }

    /** Cursor is in a CE and moving down to a media element. */
    if(e.keyCode === 40 && depth === CE.children.length-1 && this.props.storeIndex < this.props.editor.dom.length-1) {
      let Editable = Utils.getParentOfCE(CE);
      let nodeToFocus = Editable.children[this.props.storeIndex+1];
      nodeToFocus.focus();
    }

    /**
     * Primarily for Firefox.
     * This will look ahead going up or down the main children branch and seeing if there are empty parapraphs.
     * Firefox will stunt the getSelection API and return the contenteditable div always.  The fix is to add a br tag before we
     * get to the node.  Note that the parsers clean up every br at every render.
     */
    if(e.keyCode === 40 && parentNode.nextSibling) {
      if(parentNode.nextSibling.childNodes.length < 1) {
        parentNode.nextSibling.appendChild(document.createElement('br'));
      } else if(parentNode.nodeName === 'UL') {
        let li = Utils.getListItemFromTextNode(anchorNode);
        if(li && li.nextSibling && li.nextSibling.nodeName === 'LI' && li.nextSibling.textContent.length < 1) {
          li.nextSibling.appendChild(document.createElement('br'));
        }
      }
    } else if(e.keyCode === 38 && parentNode.previousSibling) {
      if(parentNode.previousSibling.childNodes.length < 1) {
        parentNode.previousSibling.appendChild(document.createElement('br'));
      } else if(parentNode.nodeName === 'UL') {
        let li = Utils.getListItemFromTextNode(anchorNode);
        if(li && li.previousSibling && li.previousSibling.nodeName === 'LI' && li.previousSibling.textContent.length < 1) {
          li.previousSibling.appendChild(document.createElement('br'));
        }
      }
    }

    /** A span gets placed in converted empty LI's.  This will replace the span for a br so that the node has dimensions in Chrome. */
    if(e.keyCode === 40 && parentNode.nodeName === 'UL') {
      let li = Utils.getListItemFromTextNode(anchorNode);
      if(li &&
         li.nextSibling &&
         li.nextSibling.nodeName === 'LI' &&
         li.nextSibling.textContent.length < 1 &&
         li.nextSibling.childNodes.length &&
         li.nextSibling.childNodes[0].nodeName === 'SPAN') {
        li.nextSibling.replaceChild(document.createElement('br'), li.nextSibling.childNodes[0]);
      }
    }
  },

  handleSpacebar(e) {
    let { sel, range, parentNode } = Utils.getSelectionData();
    let text = range.startContainer.textContent.substring(0, range.startOffset).split(' ');

    if(Utils.hasValidUrl(text[text.length-1])) {
      Utils.transformTextToAnchorTag(sel, range, true);
    }
  },

  onKeyDown(e) {
    /** Command || Ctrl - Z && Command + Shift + Z || Ctrl - Y */
    if((e.keyCode === 90 && (e.ctrlKey || e.metaKey) || e.keyCode === 90 && e.keyCode === 17) && !e.shiftKey) {
      this.handleUndo(e);
      return;
    } else if((e.keyCode === 89 && e.ctrlKey) || (e.keyCode === 89 && e.keyCode === 17) || (e.keyCode === 90 && e.metaKey && e.shiftKey)) {
      this.handleRedo(e);
      return;
    }

    let { sel, range, parentNode, anchorNode } = Utils.getSelectionData();
    let CE = ReactDOM.findDOMNode(this);

    if(!range) { return; }

    /** Primarily for Firefox.  Sets the range from CE to the first P. */
    if(CE.children.length === 1 && CE.firstChild.textContent.length < 1 && !CE.firstChild.childNodes[0]) {
      range.selectNodeContents(CE.firstChild);
      sel.setSingleRange(range);
    }

    /** If user deleted the paragraph under a PRE */
    if(CE.lastChild && CE.lastChild.nodeName === 'PRE') {
      this.createBlockElement('p', CE.children.length, false, this.props.storeIndex);
      this.props.actions.forceUpdate(true);
    }

    /** Removes placeholder text.  Used mainly for video placeholder.  Enter is handled in handleEnterKey under P. */
    if(parentNode.classList && parentNode.classList.contains('react-editor-placeholder-text') && e.keyCode !== 13) {
      parentNode.classList.remove('react-editor-placeholder-text');
      parentNode.textContent = '';
      parentNode.appendChild(document.createElement('br'));
      this.emitChange();
    }

    /** Set current storeIndex */
    if(this.props.editor.currentStoreIndex !== this.props.storeIndex) {
      this.props.actions.setCurrentStoreIndex(this.props.storeIndex);
    }

    /** Edge will put the cursor inside of a br, we need to replace it with a span. */
    if(anchorNode.parentNode && anchorNode.parentNode.nodeName === 'BR') {
      let span = document.createElement('span');
      span.textContent = anchorNode.parentNode.textContent;
      anchorNode.parentNode.parentNode.replaceChild(span, anchorNode.parentNode);
    }

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
      case 32: // SPACEBAR
        this.handleSpacebar(e);
        break;
      case 38: // UP ARROW
      case 40: // DOWN ARROW
        this.handleArrowKeys(e);
        break;
    default:
      break;
    }
  },

  onKeyUp(e) {
    /** Command || Ctrl - Z && Command + Shift + Z || Ctrl - Y */
    if((e.keyCode === 90 && (e.ctrlKey || e.metaKey) || e.keyCode === 90 && e.keyCode === 17) && !e.shiftKey) {
      return;
    } else if((e.keyCode === 89 && e.ctrlKey) || (e.keyCode === 89 && e.keyCode === 17) || (e.keyCode === 90 && e.metaKey && e.shiftKey)) {
      return;
    }

    if(e.keyCode === undefined || e.type === 'mouseup') {
      let { sel, range, anchorNode } = Utils.getSelectionData();
      if(sel === null) { return; }

      /** Trigger Anchor PopUp when it's selected. */
      if(Utils.isSelectionInAnchor(anchorNode)) {
        this.handlePopOver(true);
      }

    } else {
      this.trackCursor(e);

      /** For IE Only!  onInput is NOT supported in content-editable divs, so we listen for changes here. */
      if(this.props.editor.isIE) {
        this.debouncedEmitChange();
      }

      if(this.props.editor.hasUnsavedChanges === false) {
        this.props.actions.hasUnsavedChanges(true);
      }
    }
  },

  onMouseOver(e) {
    let node = ReactDOM.findDOMNode(e.target),
        parent = Utils.getRootParentElement(node),
        depth = Utils.findChildsDepthLevel(parent, parent.parentNode);

    if(node.nodeName === 'IMG' && parent.classList.contains('react-editor-video') && this.props.editor.showImageToolbar === false) {
      this.props.actions.toggleImageToolbar(true, { node: parent, depth: depth , top: parent.offsetTop, height: node.offsetHeight, width: node.offsetWidth, left: node.offsetLeft, type: 'video' });
    }
  },

  onClick(e) {
    let node = ReactDOM.findDOMNode(e.target);
    let { sel, range, depth, parentNode, startOffset, anchorNode } = Utils.getSelectionData();

    if(sel === null) { return; }

    this.props.actions.setCursorPosition(depth, parentNode, startOffset, anchorNode, ReactDOM.findDOMNode(this).getAttribute('data-hash'));

    /** Set current storeIndex */
    if(this.props.editor.currentStoreIndex !== this.props.storeIndex) {
      this.props.actions.setCurrentStoreIndex(this.props.storeIndex);
    }

    /** Removes a pesky image overlay. */
    this.props.actions.toggleImageToolbar(false, {});

    /** Mostly for anchor popups. */
    this.trackCursor(e);

    /** Handles Triple Click. Forces the selection to wrap the startContainers element. */
    if(e.detail >= 3) {
      e.preventDefault();
      range.selectNode(parentNode);
      sel.setSingleRange(range);
    }
  },

  handleDoubleClick(e) {
    let { range } = Utils.getSelectionData();

    /** Trigger Anchor PopUp when it's selected. */
    if(Utils.isSelectionInAnchor(range.startContainer)) {
      this.handlePopOver(true);
    }
  },

  handleUndo(e) {
    this.preventEvent(e);
    if(this.props.editor.isDataLoading) {
      this.props.actions.toggleErrorMessenger(true, 'Please wait for the image to finish uploading');
      return;
    }

    let state = this.props.actions.getPreviousHistoryState();

    if(!state) return;

    this.props.actions.setEditorState({
      ...state,
      domUpdated: false,
      isDataLoading: false,
      forceUpdate: true
    });
  },

  handleRedo(e) {
    this.preventEvent(e);
    let state = this.props.actions.getNextHistoryState();

    if(!state) return;

    this.props.actions.setEditorState({
      ...state,
      domUpdated: false,
      isDataLoading: false,
      forceUpdate: true
    });
  },

  handlePaste(e) {
    this.preventEvent(e);
    let pastedText, dataType;
    let { sel, range, parentNode, depth, commonAncestorContainer } = Utils.getSelectionData();
    let endParent = Utils.getRootParentElement(range.endContainer);
    let endDepth = Utils.findChildsDepthLevel(endParent, ReactDOM.findDOMNode(this));

    if(parentNode.classList && parentNode.classList.contains('react-editor-placeholder-text')) {
      parentNode.classList.remove('react-editor-placeholder-text');
      parentNode.textContent = '';
      parentNode.appendChild(document.createElement('br'));
    }

    if(window.clipboardData && window.clipboardData.getData) {
      /** IE */
      pastedText = window.clipboardData.getData('Text');
      dataType = 'text';
    } else if(e.clipboardData && e.clipboardData.getData) {
      let clipboardDataTypes = [].slice.apply(e.clipboardData.types);
      if(clipboardDataTypes && clipboardDataTypes.indexOf('text/html') === 1) {
        pastedText = e.clipboardData.getData('text/html');
        dataType = 'html';
      } else {
        pastedText = e.clipboardData.getData('text/plain');
        dataType = 'text';
      }
    }

    if(pastedText.length < 1) { return; }

    if(dataType === 'text') {
      pastedText = Parser.stringifyLineBreaksToParagraphs(pastedText, parentNode.nodeName);
    }

    if(pastedText.match(/(<table)/g)) {
      let liveNode = Parser.toLiveHtml(pastedText, { body: true });
      let table;
      domWalk(liveNode, (child, root, depth) => {
        if(child.nodeName === 'TABLE') {
          table = child;
        } else if(child.nodeName === 'TR' && child.textContent.length) {
          let p = document.createElement('p');
          p.textContent = child.textContent;
          liveNode.appendChild(p);
        }
        return child;
      });
      liveNode.contains(table) ? liveNode.removeChild(table) : true;
      pastedText = liveNode.innerHTML;
    }

    let liveNode = Parser.toLiveHtml(pastedText, { createWrapper: true });
    let swappedIds = Parser.replaceHashIds(liveNode);
    let cleaned = Parser.cleanEmptyElements(swappedIds);

    range.deleteContents();
    let wrapperNode = document.createElement('div');
    let cursorDataNode, cursorDataAnchorNode;

    // If pasting into a block element that is NOT a P, we need to create seperate lines.
    // Else we just insert the node at the cursor position.
    if(cleaned.childNodes.length > 1 && parentNode.nodeName !== 'P') {
      let childNodes = [].slice.call(cleaned.childNodes);

      range.insertNode(childNodes.shift());
      wrapperNode.appendChild(parentNode.cloneNode(true));

      [].slice.call(childNodes).forEach((child, index) => {
        let nodeName = parentNode.nodeName;
        let newNode = document.createElement(nodeName);
        newNode.innerHTML = child.innerHTML;
        wrapperNode.appendChild(newNode);
      });

      cursorDataNode = cleaned.lastChild;
      cursorDataAnchorNode = cleaned.lastChild;
    } else {
      // If theres text after the cursor, transform any paragraphs to spans to keep the current paragraph whole.
      if(parentNode.nodeName === 'P' && cleaned.nodeName === 'P' && range.endOffset < parentNode.textContent.length) {
        let span = document.createElement('span');
        [].slice.call(cleaned.childNodes).forEach(child => {
          if(child.nodeName === 'P') {
            let s = document.createElement('span');
            s.innerHTML = child.innerHTML;
            span.appendChild(s);
          } else {
            span.appendChild(child);
          }
        });
        cleaned = span;
      }

      range.insertNode(cleaned);
      cursorDataNode = dataType === 'text' ? cleaned : parentNode;
      cursorDataAnchorNode = cleaned;
      wrapperNode.innerHTML = parentNode.outerHTML;
    }

    return Utils.parseDescription(wrapperNode.innerHTML)
      .then(results => {
        if(!results.length) { return; }
        /** REMOVE ANYTHING BUT TEXT FOR NOW! THIS RETURNS ONLY CE'S AND FILTERS IMAGES.*/
        let clean = results.filter(item => {
          return item.type === 'CE';
        }).reduce((acc, curr) => {
          acc.json = acc.json.concat(curr.json);
          return acc;
        });

        clean.json = Parser.removeAttributes(clean.json);
        this.props.actions.handlePastedHTML(clean, depth, this.props.storeIndex, endDepth, { node: cursorDataNode, anchorNode: Utils.getLastTextNode(cursorDataAnchorNode), offset: range.startOffset + cursorDataAnchorNode.textContent.length });
        this.props.actions.forceUpdate(true);
      })
      .catch(err => { console.log('Paste Error', err); });
  },

  render() {
    return (
      <div
        data-hash={this.props.hash}
        className="no-outline-focus content-editable"
        style={this.props.style || null}
        onInput={this.onInput}
        onKeyDown={this.onKeyDown}
        onKeyUp={this.onKeyUp}
        onMouseUp={this.onKeyUp}
        onMouseOver={this.onMouseOver}
        onDoubleClick={this.handleDoubleClick}
        onClick={this.onClick}
        onPaste={this.handlePaste}
        contentEditable={true}
        dangerouslySetInnerHTML={{__html: this.props.html}}></div>
    );
  }
});

export default ContentEditable;