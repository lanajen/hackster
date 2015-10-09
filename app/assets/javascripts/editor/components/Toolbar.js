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
      this.debouncedScroll = _.debounce(this.handleScroll, 10);
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
    let scrollTop = el.getBoundingClientRect().top;
    let windowPos = window.pageYOffset;

    if(scrollTop <= 0 && this.state.toolbarTopPos === null && this.state.toolbarTopPos < windowPos && !el.classList.contains('fixed-toolbar')) {
      el.classList.add('fixed-toolbar');

      this.setState({
        toolbarTopPos: windowPos
      }); 

    } else if (this.state.toolbarTopPos >= windowPos && el.classList.contains('fixed-toolbar')) {
      el.classList.remove('fixed-toolbar');

      this.setState({
        toolbarTopPos: null
      });
    }
  },

  handleExecCommand(tagType, valueArg) {
    valueArg = valueArg || null;
    if(document) {
      document.execCommand(tagType, false, valueArg);
      
      let { sel, anchorNode, parentNode } = Utils.getSelectionData();

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

    if(parentNode.nodeName === 'DIV' && parentNode.classList.contains('react-editor-carousel')
       || parentNode.nodeName === 'DIV' && parentNode.classList.contains('react-editor-video')) {  // Don't transform Media.
      return;
    }

    if(isNodeInUL && blockEls[tagType.toUpperCase()]) {
      this.props.actions.transformListItemsToBlockElements(tagType, depth, this.props.editor.currentStoreIndex);
      this.props.actions.forceUpdate(true);
      return;
    } else if(Utils.isCommonAncestorContentEditable(commonAncestorContainer)) {  // Multiple lines are selected.
      let startContainer = Utils.getRootParentElement(range.startContainer);
      let endContainer = Utils.getRootParentElement(range.endContainer);
      let arrayOfNodes = Utils.createArrayOfDOMNodes(startContainer, endContainer, commonAncestorContainer);

      /** Restricts transformations if theres a div (Media block) in the selection */
      if(_.some(arrayOfNodes, { nodeName: 'DIV' })) {
        return;
      } else {
        this.props.actions.transformBlockElements(tagType, arrayOfNodes, this.props.editor.currentStoreIndex);
        this.props.actions.forceUpdate(true);
      }
    } else {
      this.props.actions.transformBlockElement(tagType, depth, false, this.props.editor.currentStoreIndex);
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
       && !blockEls[Utils.getRootParentElement(range.startContainer).nodeName] && range.getNodes([3]).length <= 1) {
      /** Builds the selected text from scratch honoring all wrapped node types.  We delete the selection in the Promise handler. */
      let selectedHtml = range.toHtml();
      let selectedBuild = Utils.getParentNodeByElement(anchorNode, 'P');
      let newNodeTree = Utils.createNewNodeTree(selectedBuild.childNodes, selectedHtml);

      let parentHtml = parentNode.innerHTML;
      let startIndex = parentHtml.indexOf(selectedHtml);

      let intro = parentHtml.slice(0, startIndex);
      let blockquote = newNodeTree.innerHTML;
      let outro = parentHtml.slice(startIndex + selectedHtml.length);

      let promises = [ intro, blockquote, outro ].map(html => {
        return Parser.parseDOM(html);
      });
      console.log('TEXT', range.toHtml(), selectedHtml, range.commonAncestorContainer);
      console.log('INTRO: ' + intro, ' BQ: ' + blockquote, ' OUTRO: ' + outro);
      Promise.all(promises)
        .then(results => {
          this.props.actions.splitBlockElement(tagType, results, depth, this.props.editor.currentStoreIndex);
          this.props.actions.setCursorToNextLine(true);
          this.props.actions.forceUpdate(true);
          range.deleteContents();
        })
        .catch(err => {
          //TODO: Handle Err;
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
      'H3': true
    };

    /** Quicky to undo a code block if nothing is selected and user want to just undo a code at that position. */
    if(range.startOffset === range.endOffset && Utils.isChildOfCode(anchorNode)) {
      return;
    }

    /** If there's selected text and the selection is within the same element, wrap the text in a CODE tag. 
      * Else we're going to transform the selection or blocks into a PRE tags.
     */
    if(range.startOffset !== range.endOffset && Utils.getRootParentElement(range.startContainer) === Utils.getRootParentElement(range.endContainer)
       && !blockEls[Utils.getRootParentElement(range.startContainer).nodeName]) {

      let ranges = { start: range.startOffset, end: range.endOffset };
      let selectedText = range.commonAncestorContainer.textContent.slice(ranges.start, ranges.end);

      /** Mutating the DOM here. We first check for CODE removal, if not, we add a CODE node. */
      if(Utils.isNodeChildOfElement(range.startContainer, 'CODE') || Utils.isNodeChildOfElement(range.endContainer, 'CODE')) {
        let textNode = document.createTextNode(selectedText);
        let codeContainer = Utils.isNodeChildOfElement(range.startContainer, 'CODE') ? range.startContainer : range.endContainer;
        let { parent, childNodes } = Utils.getParentNodeByElement(codeContainer, 'CODE');
        /** If all the text is selected, replace CODE block with a textNode.
          * Else we need to split the element apart and create those nodes.
         */
        if(selectedText === parent.textContent) {
          parent.parentNode.replaceChild(textNode, parent);
        } else if(range.getNodes([3]).length > 1) {
          /** Concat all the text together, remove the current selection and replace it with a new TextNode. */
          selectedText = range.getNodes([3])
            .map(node => {
              return node.textContent;
            })
            .reduce((a, b) => {
              return a + b;
            }, '');
          range.deleteContents();
          textNode = document.createTextNode(selectedText);
          parent.parentNode.replaceChild(textNode, parent);
        } else {
          let start = parent.textContent.slice(0, range.startOffset);
          let middle = parent.textContent.slice(range.startOffset, range.endOffset);
          let end = parent.textContent.slice(range.endOffset);
          range.deleteContents();
          /** If start doesn't have a length, then the selection starts @ index 0. 
            * Else if the selection is in the middle of the text, create two new nodes.
            * Else selection is at the end of the node, append a child node if last or insert before the next node.
            */
          if(!start.length) {
            textNode.textContent = parent.textContent;
            parent.parentNode.insertBefore(textNode, parent);
          } else if(start.length && end.length) {
            let code = document.createElement('code');
            code.textContent = end;
            parent.textContent = start;
            parent.parentNode.insertBefore(code, parent.nextSibling);
            parent.parentNode.insertBefore(textNode, parent.nextSibling);
          } else {
            if(parent.parentNode.lastChild === parent) {
              parent.parentNode.appendChild(textNode);
            } else {
              parent.parentNode.insertBefore(textNode, parent.nextSibling);
            }
          }
        }
        /** Cleans up the dom tree. */
        parentNode.normalize();
        /** Reselect the text. */
        range.selectNodeContents(textNode);
        sel.setSingleRange(range);
        /** Let the store know about the mutation. */
        this.props.actions.getLatestHTML(true);
      } else {
        let code = document.createElement('code');
        code.innerHTML = range.toHtml();
        range.deleteContents();
        range.insertNode(code);
        /** Cleans up the dom tree. */
        parentNode.normalize();
        this.mergeAdjacentElements(parentNode);
        /** Reselect the text. */
        range.selectNodeContents(code.childNodes[0]);
        sel.setSingleRange(range);
        /** Let the store know about the mutation. */
        this.props.actions.getLatestHTML(true);
      }
    } else {
      this.handleBlockElementTransform(tagType);
    }
  },

  mergeAdjacentElements(parentNode) {
    let children = [].slice.apply(parentNode.childNodes);

    children.forEach(child => {
      if(child.nextSibling && child.nextSibling.nodeName === child.nodeName) {
        let nextData = child.nextSibling.innerHTML;
        child.innerHTML += nextData;
        parentNode.removeChild(child.nextSibling);
      }
    });
  },


  handleUnorderedList() {
    let { sel, range, parentNode } = Utils.getSelectionData();
    let startContainerParent = Utils.getRootParentElement(range.startContainer);
    let endContainerParent = Utils.getRootParentElement(range.endContainer);
    let elements = [];

    if(parentNode.nodeName === 'DIV' && parentNode.classList.contains('react-editor-carousel')
       || parentNode.nodeName === 'DIV' && parentNode.classList.contains('react-editor-video')) {  // Don't transform Media.
      return;
    }

     if(startContainerParent.nodeName === 'UL') {  // Undo UL.
      if(range.startContainer.nodeType === 3 || range.startContainer.localName === 'li') { // Is TextNode.  The cursor is placed after element or multiline select.
        
        if(startContainerParent !== endContainerParent) { // Multiple block elements are selected.
          let obj = {};
          let allNodes = Utils.getAllNodesInSelection(startContainerParent, endContainerParent, parentNode);
          allNodes = allNodes.filter(function(node) { return node.localName === 'ul'; });
  
          _.forEach(allNodes, function(ul, index) {
            if(index === 0) {
              obj[Utils.findChildsDepthLevel(ul, ul.parentNode)] = { node: ul, start: range.startContainer, end: ul.lastChild, hash: ul.getAttribute('data-hash')};
            } else if(index === allNodes[allNodes.length-1]) {
              obj[Utils.findChildsDepthLevel(ul, ul.parentNode)] = { node: ul, start: ul.firstChild, end: range.endContainer, hash: ul.getAttribute('data-hash') };
            } else {
              obj[Utils.findChildsDepthLevel(ul, ul.parentNode)] = { node: ul, start: ul.firstChild, end: ul.lastChild, hash: ul.getAttribute('data-hash') };
            }
          });

          for(let i in obj) {
            if(obj.hasOwnProperty(i)) {
              let ul = obj[i];
              elements = Utils.getListItemPositions(ul.start, ul.end, ul.node);
              this.props.actions.handleUnorderedList(false, elements, { depth: parseInt(i), hash: ul.hash }, this.props.editor.currentStoreIndex);
            }
          }
        } else {
          elements = Utils.getListItemPositions(range.startContainer, range.endContainer, parentNode);
          this.props.actions.handleUnorderedList(false, elements, { depth: Utils.findChildsDepthLevel(parentNode, parentNode.parentNode), hash: null }, this.props.editor.currentStoreIndex);
        }

      } else if(range.startContainer.nodeType === 1 && range.startContainer === parentNode) { // Cursor is before single element.
        elements = [Utils.findChildsDepthLevel(sel.anchorNode, parentNode)];
        this.props.actions.handleUnorderedList(false, elements, { depth: Utils.findChildsDepthLevel(parentNode, parentNode.parentNode), hash: null }, this.props.editor.currentStoreIndex);
      } else {
        return;
      }
    } else {  // Build UL.
      if(startContainerParent === endContainerParent) { // One block element is selected.
        elements = [{ depth: Utils.findChildsDepthLevel(startContainerParent, startContainerParent.parentNode) }];
        this.props.actions.handleUnorderedList(true, elements, { depth: null, hash: null, previousLength: null }, this.props.editor.currentStoreIndex);
      } else {  // Multiple blocks are selected.
        let listGroups = Utils.createULGroups(startContainerParent, endContainerParent, parentNode.parentNode);
        listGroups.forEach((group, index) => {
          let previousLength = null;
          /** 
            * We pass the previous arrays length so we can subtract that number from the current depth.
            * We need to do this to get proper depth placement when the DOM is being mutated into ULs.
           */
          if(listGroups.length > 1 && index !== 0) { 
            previousLength = listGroups[index-1].length;
          }
          elements = Utils.createArrayOfDOMNodes(group[0], group[group.length-1], parentNode.parentNode);
          this.props.actions.handleUnorderedList(true, elements, { depth: null, hash: null, previousLength: previousLength}, this.props.editor.currentStoreIndex);
        });

      }

    }
    this.props.actions.forceUpdate(true);
  },

  handleLinkClick() {
    let { sel, range, anchorNode, parentNode } = Utils.getSelectionData();

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
          href = 'http://' + href;
        }
        this.handleExecCommand('createLink', href);
        /** Grabs the selection again after the DOM was mutated by execCommand. */
        sel = rangy.getSelection();
        sel.setSingleRange(range);
        sel.collapseToEnd();
      } else {
        this.props.actions.toggleErrorMessenger(true, 'Not a valid url');
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
        return true;
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
      let storeIndex = this.props.editor.currentStoreIndex;
      this.props.actions.isDataLoading(true);
      this.props.actions.createMediaByType(map, depth, storeIndex, 'Carousel');
      this.props.actions.forceUpdate(true);

      /** Upload files to AWS. */
      this.props.actions.uploadImagesToServer(
        map,
        storeIndex, 
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

  render: function() {
    // console.log('TOOLBAR', this.state.showPopOver);
  
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
      return <Button key={Helpers.createRandomNumber()} classList={button.classList} tagType={button.tagType} icon={button.icon} activeButtons={this.props.toolbar.activeButtons} onClick={button.onClick} onError={this.handleToolbarButtonError} />;
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