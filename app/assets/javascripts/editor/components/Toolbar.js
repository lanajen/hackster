import React from 'react';
import Button from './ToolbarButton';
import PopOver from './PopOver';
import _ from 'lodash';
import validator from 'validator';
import rangy from 'rangy';
import Utils from '../utils/DOMUtils';
import ImageUtils from '../../utils/Images';
import Helpers from '../../utils/Helpers';
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
    let blockEls = {
      'blockquote': true,
      'pre': true
    };

    if(parentNode.nodeName === 'DIV' && parentNode.classList.contains('react-editor-carousel')
       || parentNode.nodeName === 'DIV' && parentNode.classList.contains('react-editor-video')) {  // Don't transform Media.
      return;
    }

    if(isNodeInUL && blockEls[tagType]) { // Cleans UL's lis if transforming.
      this.props.actions.transformListItemsToBlockElements(tagType, depth);
      this.props.actions.forceUpdate(true);
    } else if(Utils.isCommonAncestorContentEditable(commonAncestorContainer)) {  // Multiple lines are selected.
      let startContainer = Utils.getRootParentElement(range.startContainer);
      let endContainer = Utils.getRootParentElement(range.endContainer);
      let arrayOfNodes = Utils.createArrayOfDOMNodes(startContainer, endContainer, commonAncestorContainer);

      /** Restricts transformations if theres a div (Media block) in the selection */
      if(_.some(arrayOfNodes, { nodeName: 'DIV' })) {
        // TODO: HANDLE ERROR!!!!!!!!!!!!!!!
        console.log('throw err');
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

  handleUnorderedList() {
    let { sel, range, parentNode } = Utils.getSelectionData();
    let startContainerParent = Utils.getRootParentElement(range.startContainer);
    let endContainerParent = Utils.getRootParentElement(range.endContainer);
    let blockEls = {
      'blockquote': true,
      'pre': true
    };
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
        console.log('ALSO CHECK THIS', elements);
        this.props.actions.handleUnorderedList(false, elements, { depth: Utils.findChildsDepthLevel(parentNode, parentNode.parentNode), hash: null }, this.props.editor.currentStoreIndex);
      } else {
        return;
      }
    } else {  // Build UL.
      if(startContainerParent === endContainerParent) { // One block element is selected.
        elements = [{ depth: Utils.findChildsDepthLevel(startContainerParent, startContainerParent.parentNode) }];
        console.log('HIT', this.props.editor.currentStoreIndex);
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
      if(validator.isURL(href)) {
        let sel = rangy.getSelection();
        sel.setSingleRange(range);
        this.handleExecCommand('createLink', href);
        /** Grabs the selection again after the DOM was mutated by execCommand. */
        sel = rangy.getSelection();
        sel.setSingleRange(range);
        sel.collapseToEnd();
      } else {
        // TODO: HANDLE ERROR.
        console.log('NOT A VALID URL');
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
  },

  handleAnchorTagRemoval() {
    let sel = rangy.getSelection();
    let range = sel.getRangeAt(0);
    range.selectNodeContents(range.startContainer);
    sel.addRange(range);
    this.handleExecCommand('unlink', 'p');
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
    filteredFiles = _.filter(files, function(file) {
      if(Helpers.isImageValid(file.type)) {
        return file;
      } else {
        return false;
      }
    });

    ImageUtils.handleImagesAsync(files, function(map) {
      let storeIndex = this.props.editor.currentStoreIndex;
      this.props.actions.isDataLoading(true);
      this.props.actions.createMediaByType(map, depth, storeIndex, 'Carousel');
      this.props.actions.forceUpdate(true);

      /** Upload files to AWS. */
      this.props.actions.uploadImagesToServer(
        map, 
        storeIndex, 
        this.props.editor.S3BucketURL, 
        this.props.editor.AWSAccessKeyId, 
        this.props.editor.csrfToken, 
        this.props.editor.projectId
      );

    }.bind(this));

    React.findDOMNode(this.refs.imageUploadInput).value = '';
  },

  handleVideoButtonClick() {
    let { depth } = Utils.getSelectionData();
    this.props.actions.createPlaceholderElement('Paste a link to Youtube, Vimeo or Vine and press Enter', depth, this.props.editor.currentStoreIndex);
    this.props.actions.forceUpdate(true);
  },

  render: function() {
    // console.log('TOOLBAR', this.state.showPopOver);
  
    let linkPopOver = this.props.toolbar.showPopOver ? (
      <PopOver ref="popOver" popOverProps={this.props.toolbar.popOverProps} editor={this.props.editor} onLinkInput={this.handleLinkInput} unMountPopOver={this.unMountPopOver} onVersionChange={this.handlePopOverChange} onInputChange={this.handlePopOverInputChange} removeAnchorTag={this.handleAnchorTagRemoval}/>
    ) : null;

    let buttonList = [
      { classList: 'toolbar-btn', tagType: 'bold', icon: 'fa fa-bold', onClick: this.handleExecCommand },
      { classList: 'toolbar-btn', tagType: 'italic', icon: 'fa fa-italic', onClick: this.handleExecCommand},
      { classList: 'toolbar-btn', tagType: 'anchor', icon: 'fa fa-link', onClick: this.handleLinkClick},
      { classList: 'toolbar-btn', tagType: 'blockquote', icon: 'fa fa-quote-right', onClick: this.handleBlockElementTransform},
      { classList: 'toolbar-btn', tagType: 'pre', icon: 'fa fa-code', onClick: this.handleBlockElementTransform},
      { classList: 'toolbar-btn', tagType: 'ul', icon: 'fa fa-list', onClick: this.handleUnorderedList},
      { classList: 'toolbar-btn', tagType: 'carousel', icon: 'fa fa-picture-o', onClick: this.handleImageButtonClick},
      { classList: 'toolbar-btn', tagType: 'video', icon: 'fa fa-video-camera', onClick: this.handleVideoButtonClick}
    ];

    let Buttons = buttonList.map(button => {
      return <Button key={Helpers.createRandomNumber()} classList={button.classList} tagType={button.tagType} icon={button.icon} activeButtons={this.props.toolbar.activeButtons} onClick={button.onClick} />;
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