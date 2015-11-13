import React from 'react';
import Button from './ToolbarButton';
import PopOver from './PopOver';
import _ from 'lodash';
import Validator from 'validator';
import rangy from 'rangy';
import Utils from '../utils/DOMUtils';
import ImageUtils from '../../utils/Images';
import Helpers from '../../utils/Helpers';
import Parser from '../utils/Parser';
import InlineBlockModel from '../models/InlineBlock';
import BlockModel from '../models/Block';
import ListModel from '../models/List';
import { BlockElements } from '../utils/Constants';
import { LinearProgress } from 'material-ui';

const Toolbar = React.createClass({

  getInitialState() {
    return {
      toolbarTopPos: null,
    };
  },

  componentDidMount() {
    if(window) {
      this.debouncedScroll = _.debounce(this.handleScroll, 10, true);
      window.addEventListener('scroll', this.debouncedScroll);
    }
  },

  componentWillUnmount() {
    if(window) {
      window.removeEventListener('scroll', this.debouncedScroll);
    }
  },

  handleScroll(e) {
    let el = React.findDOMNode(this.refs.toolbar);
    let parentTop = el.parentNode.getBoundingClientRect().top;

    if (parentTop < 0) {
      if (!el.classList.contains('fixed-toolbar'))
        el.classList.add('fixed-toolbar');
    } else {
      if (el.classList.contains('fixed-toolbar'))
        el.classList.remove('fixed-toolbar');
    }
  },

  focusCE() {
    let rootHash = this.props.editor.cursorPosition.rootHash;
    let currentCE = document.querySelector(`div[data-hash="${rootHash}"]`);
    currentCE.focus();
  },

  handleExecCommand(tagType, valueArg) {
    let { sel, anchorNode, parentNode } = Utils.getSelectionData();
    valueArg = valueArg || null;

    /** Don't allow H3's to be styled. */
    if(parentNode.nodeName === 'H3') {
      this.props.actions.toggleErrorMessenger(true, 'Sorry, titles can\'t be styled.');
      return;
    }

    if(document) {
      document.execCommand(tagType, false, valueArg);
      this.focusCE();
      this.handleUnsavedChanges();


      if(sel !== null) {
        let list = Utils.createListOfActiveElements(anchorNode, parentNode);
        this.props.actions.toggleActiveButtons(list);
      }
    }
  },

  handleBlockElementTransform(tagType) {
    let { sel, range, commonAncestorContainer, parentNode, depth } = Utils.getSelectionData();
    let isNodeInUL = Utils.isNodeInUL(commonAncestorContainer);
    let blockEls = BlockElements;

    if(isNodeInUL && blockEls[tagType.toUpperCase()]) { // Cleans UL's lis if transforming.
      // this.props.actions.transformListItemsToBlockElements(tagType, depth, this.props.editor.currentStoreIndex);
      // this.handleUnsavedChanges();
      // this.props.actions.forceUpdate(true);
      this.props.actions.toggleErrorMessenger(true, 'List items cannot tranform into a ' + tagType);
      return;
    } else if(Utils.isCommonAncestorContentEditable(commonAncestorContainer)) {  // Multiple lines are selected.
      let startContainer = Utils.getRootParentElement(range.startContainer);
      let endContainer = Utils.getRootParentElement(range.endContainer);
      let arrayOfNodes = Utils.createArrayOfDOMNodes(startContainer, endContainer, commonAncestorContainer);

      /** Restricts transformations if theres a div (Media block) in the selection. */
      if(_.some(arrayOfNodes, { nodeName: 'DIV' })) {
        return;
      } else {
        this.props.actions.transformBlockElements(tagType, arrayOfNodes, this.props.editor.currentStoreIndex);
        this.handleUnsavedChanges();
        this.props.actions.forceUpdate(true);
      }
    } else {
      this.props.actions.transformBlockElement(tagType, depth, false, this.props.editor.currentStoreIndex);
      this.handleUnsavedChanges();
      this.props.actions.forceUpdate(true);
    }
  },

  handleBlockquote(tagType) {
    let { sel, range, depth, anchorNode, parentNode } = Utils.getSelectionData();
    /** Do not add a P to this.  We only split a selected text node if its wrapped in a P. */
    let blockEls = {
      'PRE': true,
      'UL': true,
      'H3': true,
      'BLOCKQUOTE': true
    };

    /** If theres selected text (NOT in a block element or if selection spans multiple nodes), break the paragraph apart into three segments.
      * Else turn the selection/s to a normal Blockquote.
     */
    if(range.startOffset !== range.endOffset && range.toString() !== parentNode.textContent
       && Utils.getRootParentElement(range.startContainer) === Utils.getRootParentElement(range.endContainer)
       && !blockEls[Utils.getRootParentElement(range.startContainer).nodeName] && range.getNodes([3]).length <= 1
       && range.toString().trim().length > 0) {

      let { top, middle, bottom } = BlockModel.splitTextAtSelection(range, anchorNode, parentNode);
      let promises = [ top, middle, bottom ].map(html => {
        return Parser.parseDOM(html);
      });

      Promise.all(promises)
        .then(results => {
          this.props.actions.splitBlockElement(tagType, results, depth, this.props.editor.currentStoreIndex);
          this.props.actions.setCursorToNextLine(true);
          this.props.actions.forceUpdate(true);
          this.handleUnsavedChanges();
          range.deleteContents();
        })
        .catch(err => {
          console.log('ERR:' + err);
        });
    } else {
      this.handleBlockElementTransform(tagType);
    }
  },

  handleHeader(tagType) {
    this.handleBlockElementTransform(tagType);
  },

  handlePre(tagType) {
    let data = Utils.getSelectionData();
    let { sel, range, depth, anchorNode, parentNode } = data;
    let blockEls = {
      'PRE': true,
      'H3': true,
    };

    /** If there's selected text and the selection is within the same element, wrap the text in a CODE tag.
      * Else we're going to transform the selection or blocks into a PRE tags.
     */
    if(range.startOffset !== range.endOffset
       && Utils.getRootParentElement(range.startContainer) === Utils.getRootParentElement(range.endContainer)
       && !blockEls[Utils.getRootParentElement(range.startContainer).nodeName]) {
      let clone = parentNode.cloneNode(true);
      let newHtml;

      /** Don't allow H3's to be styled. */
      if(parentNode.nodeName === 'H3') {
        this.props.actions.toggleErrorMessenger(true, 'Sorry, titles can\'t be styled.');
        return;
      }

      if(Utils.isNodeChildOfElement(range.startContainer, 'CODE') || Utils.isNodeChildOfElement(range.endContainer, 'CODE')) {
        newHtml = InlineBlockModel.removeInline(clone, range.cloneRange(), 'code');
        return Parser.parseDOM(newHtml.outerHTML)
          .then(json => {
            this.props.actions.transformInlineToText(json, depth, this.props.editor.currentStoreIndex);
            this.props.actions.forceUpdate(true);
          }).catch(err => {
            console.log(err);
          });
      } else {
        newHtml = InlineBlockModel.transformInline(parentNode, range, 'code');
        return Parser.parseDOM(newHtml.outerHTML)
          .then(json => {
            this.props.actions.transformInlineToText(json, depth, this.props.editor.currentStoreIndex);
            this.props.actions.forceUpdate(true);
          }).catch(err => {
            console.log(err);
          });
      }
      this.handleUnsavedChanges();
      this.focusCE();
    } else {
      this.handleBlockElementTransform(tagType);
    }
  },

  handleUnorderedList() {
    let { sel, range, anchorNode, parentNode, depth } = Utils.getSelectionData();
    let startContainerParent = Utils.getRootParentElement(range.startContainer);
    let endContainerParent = Utils.getRootParentElement(range.endContainer);

    if(Utils.isElementTypeInSelection(startContainerParent, endContainerParent, 'UL')) {
      /** A list exists in the current selection. */
      if(startContainerParent === endContainerParent) {
        /** Selection is in the same list; Undo list. */
        return Parser.parseDOM(parentNode.cloneNode(true).outerHTML)
          .then(json => {
            let elements = ListModel.transformListItems(json, Utils.getListItemPositions(range.startContainer, range.endContainer, parentNode), depth);
            this.props.actions.handleUnorderedList(false, elements, {}, this.props.editor.currentStoreIndex);
            this.props.actions.forceUpdate(true);
          }).catch(err => { console.log(err); });

      } else {
        /** Selection ranges outside of the list, we're going to create a list of all selected nodes. */
        this._buildList(startContainerParent, endContainerParent, parentNode);
      }

    } else {
      /** Build a fresh list. */
      this._buildList(startContainerParent, endContainerParent, parentNode);
    }
    this.handleUnsavedChanges();
    this.focusCE();
  },

  _buildList(startContainerParent, endContainerParent, parentNode) {
    let nodes = ListModel.createULGroups(startContainerParent, endContainerParent, parentNode.parentNode);
    let promises = nodes.map(node => {
      return Parser.parseDOM(node.node.outerHTML);
    });

    Promise.all(promises)
      .then(results => {
        results = results.map((item, index) => { return { json: item, hash: nodes[index].hash, depth: nodes[index].depth }});

        let list = ListModel.toList(results);
        this.props.actions.handleUnorderedList(true, list, { startDepth: results[0].depth, itemsToRemove: results.length }, this.props.editor.currentStoreIndex);
        this.props.actions.forceUpdate(true);
      });
  },

  handleLinkClick() {
    let { sel, range, anchorNode, parentNode } = Utils.getSelectionData();

    /** Don't allow H3's to be styled. */
    if(parentNode.nodeName === 'H3') {
      this.props.actions.toggleErrorMessenger(true, 'Sorry, titles can\'t be styled.');
      return;
    }

    if(sel !== null) {
      let list = Utils.createListOfActiveElements(anchorNode, parentNode);
      this.props.actions.toggleActiveButtons(list);

      if(range.startOffset !== range.endOffset) {
        if(Utils.isSelectionInAnchor(sel.anchorNode)) {
          this.handleExecCommand('unlink', 'p');
        } else {
          let props = {
            node: anchorNode,
            parentNode: document.querySelector('.box'),
            range: range,
            text: sel.toString(),
            version: 'init',
            href: ''
          };
          this.props.actions.showPopOver(true, props);
        }
      }
    }

  },

  handleLinkInput(href, text, range) {
    if(href === null) {
      return;
    } else {
      if(Validator.isURL(href)) {
        let sel = rangy.getSelection();
        sel.setSingleRange(range);
        if(!Validator.isURL(href, { require_protocol: true })) {
          //TODO: MESSAGE THAT WE ADDED HTTP.
          href = 'http://' + href;
        }
        this.handleExecCommand('createLink', href);
        this.focusCE();
        /** Grabs the selection again after the DOM was mutated by execCommand. */
        sel = rangy.getSelection();
        sel.setSingleRange(range);
        sel.collapseToEnd();
      } else {
        this.props.actions.toggleErrorMessenger(true, 'That\'s not a valid url.');
      }
    }
  },

  unMountPopOver() {
    this.props.actions.showPopOver(false, {});
  },

  handlePopOverChange(oldProps) {
    this.props.actions.showPopOver(false, {});
    let props = {
      node: oldProps.node,
      parentNode: document.querySelector('.box'),
      range: oldProps.range,
      text: oldProps.text,
      version: 'change',
      href: oldProps.href
    };
    setTimeout(() => { this.props.actions.showPopOver(true, props); }, 50);
  },

  handlePopOverInputChange(href, text, node, range) {
    let sel = rangy.getSelection();
    let anchor = Utils.getAnchorNode(range.startContainer);
    anchor.setAttribute('href', href);
    anchor.innerText = text;
    this.props.actions.getLatestHTML(true);
    Utils.setCursorByNode(anchor);
  },

  handleAnchorTagRemoval() {
    let sel = rangy.getSelection();
    let range = sel.getRangeAt(0);
    range.selectNodeContents(range.startContainer);
    sel.addRange(range);
    this.handleExecCommand('unlink', 'p');
    this.unMountPopOver();
    /** Replaces the cursor to the last known position or to the end of the current node. */
    if(this.props.editor.cursorPosition.pos  && this.props.editor.cursorPosition.pos.start) {
      sel.collapse(sel.anchorNode, this.props.editor.cursorPosition.pos.start);
    } else {
      sel.collapseToEnd();
    }
  },

  handleImageButtonClick() {
    React.findDOMNode(this.refs.imageUploadInput).click();
  },

  handleImages(e) {
    e.preventDefault();
    let files = e.target.files,
        { depth } = Utils.getSelectionData(),
        filteredFiles;

    files = Array.prototype.slice.call(files);
    filteredFiles = _.filter(files, file => {
      if(Helpers.isImageValid(file.type)) {
        return file;
      } else {
        let msg = file.name ? file.name + ' is not a valid image!' : 'Sorry, not a valid image';
        this.props.actions.toggleErrorMessenger(true, msg);
        return false;
      }
    });

    if(!filteredFiles.length) {
      return;
    }

    ImageUtils.handleImagesAsync(filteredFiles, map => {
      this.props.actions.isDataLoading(true);
      this.props.actions.createMediaByType(map, depth, this.props.editor.currentStoreIndex, 'Carousel');
      this.props.actions.forceUpdate(true);
      this.handleUnsavedChanges();

      /** Upload files to AWS. */
      this.props.actions.uploadImagesToServer(
        map,
        this.props.editor.currentStoreIndex,
        this.props.editor.lastMediaHash,
        this.props.editor.S3BucketURL,
        this.props.editor.AWSAccessKeyId,
        this.props.editor.csrfToken,
        this.props.editor.projectId
      );
    });

    React.findDOMNode(this.refs.imageUploadInput).value = '';
  },

  handleVideoButtonClick() {
    let { depth } = Utils.getSelectionData();
    this.props.actions.createPlaceholderElement('Paste a link to Youtube, Vimeo or Vine and press Enter', depth, this.props.editor.currentStoreIndex);
    this.props.actions.forceUpdate(true);
  },

  handleToolbarButtonError(tagType) {
    this.props.actions.toggleErrorMessenger(true, `Sorry, cannot transform that into a ${tagType}`);
  },

  handleUnsavedChanges() {
    if(this.props.editor.hasUnsavedChanges === false) {
      this.props.actions.hasUnsavedChanges(true);
    }
  },

  render: function() {
    let linkPopOver = this.props.toolbar.showPopOver ? (
      <PopOver ref="popOver" popOverProps={this.props.toolbar.popOverProps} editor={this.props.editor} actions={this.props.actions} onLinkInput={this.handleLinkInput} unMountPopOver={this.unMountPopOver} onVersionChange={this.handlePopOverChange} onInputChange={this.handlePopOverInputChange} removeAnchorTag={this.handleAnchorTagRemoval}/>
    ) : null;

    let buttonList = [
      { classList: 'toolbar-btn', tagType: 'bold', icon: 'fa fa-bold', onClick: this.handleExecCommand },
      { classList: 'toolbar-btn', tagType: 'italic', icon: 'fa fa-italic', onClick: this.handleExecCommand},
      { classList: 'toolbar-btn', tagType: 'h3', icon: 'fa fa-header', onClick: this.handleHeader},
      { classList: 'toolbar-btn', tagType: 'anchor', icon: 'fa fa-link', onClick: this.handleLinkClick},
      { classList: 'toolbar-btn', tagType: 'blockquote', icon: 'fa fa-quote-right', onClick: this.handleBlockquote},
      { classList: 'toolbar-btn', tagType: 'pre', icon: 'fa fa-code', onClick: this.handlePre},
      { classList: 'toolbar-btn', tagType: 'ul', icon: 'fa fa-list', onClick: this.handleUnorderedList},
      { classList: 'toolbar-btn', tagType: 'carousel', icon: 'fa fa-picture-o', onClick: this.handleImageButtonClick},
      { classList: 'toolbar-btn', tagType: 'video', icon: 'fa fa-video-camera', onClick: this.handleVideoButtonClick}
    ];

    let Buttons = buttonList.map(button => {
      return <Button key={Helpers.createRandomNumber()} classList={button.classList} tagType={button.tagType} icon={button.icon} activeButtons={this.props.toolbar.activeButtons} onClick={button.onClick} onError={this.handleToolbarButtonError}/>;
    });

    let style = {
      width: parseInt(this.props.toolbar.CEWidth, 10) || '100%'
    };

    let loader = this.props.editor.isDataLoading
               ? (<LinearProgress style={{ top: 4 }} mode="indeterminate" />)
               : null;

    return (
      <div style={style} ref="toolbar" className="react-editor-toolbar-wrapper">
        <div className="react-editor-toolbar">
          {Buttons}
        </div>
        {loader}
        <input ref="imageUploadInput" style={{display: 'none'}} type="file" multiple="true" onChange={this.handleImages}/>
        {linkPopOver}
      </div>
    );
  }

});

export default Toolbar;