import rangy from 'rangy';
import _ from 'lodash';
import async from 'async';
import HtmlParser from 'htmlparser2';
import DomHandler from 'domhandler';
import sanitizer from 'sanitizer';
import Helpers from '../../utils/Helpers';
import { BlockElements, ElementWhiteList } from './Constants';
import Request from './Requests';
import Validator from 'validator';
import { domWalk } from './Traversal';

import Hashids from 'hashids';
const hashids = new Hashids('hackster', 4);

const Utils = {

  getSelectionData() {
    let sel = rangy.getSelection();
    if(!sel || !sel.rangeCount) {
      return {
        sel: null,
        range: null,
        commonAncestorContainer: null,
        parentNode: null,
        depth: null,
        startOffset: null,
        anchorNode: null
      };
    } else {
      sel = rangy.getSelection();
      let range = sel.getRangeAt(0),
          commonAncestorContainer = range.commonAncestorContainer,
          parentNode = this.getRootParentElement(range.startContainer),
          depth = this.findChildsDepthLevel(parentNode, parentNode.parentNode);

      return {
        sel: sel,
        range: range,
        commonAncestorContainer: commonAncestorContainer,
        parentNode: parentNode,
        depth: depth,
        startOffset: range.startOffset,
        anchorNode: sel.anchorNode
      };
    }
  },

  getWindowLocationHref() {
    return window.location.href;
  },

  /**
   * Gets the block level element of the current tree dictated by a Selection object.
   * @param  {[textNodeValue]} [window.getSelection().anchorNode]
   * @return {[DOM Node]} [Parent element directly under contenteditable div.]
   */
  getRootParentElement(anchorNode) {
    let parentEl, childNode = anchorNode;

    if(anchorNode.className && anchorNode.className.split(' ').indexOf('content-editable') !== -1) {
      return anchorNode;
    }

    while(childNode.parentNode && childNode.parentNode.className !== undefined
          && childNode.parentNode.className.split(' ').indexOf('content-editable') !== 1) {
      parentEl = childNode.parentNode;
      childNode = childNode.parentNode;
    }

    return parentEl = parentEl === undefined ? childNode : parentEl;
  },

  getParentOfNodeUnderBlockElement(anchorNode, blockElement) {
    let parent;

    while(anchorNode.parentNode && !anchorNode.parentNode.classList.contains('content-editable')) {
      if(Object.is(anchorNode.parentNode, blockElement)) {
        parent = anchorNode;
        break;
      }

      anchorNode = anchorNode.parentNode;
    }

    return parent;
  },

  getRootOverlayElement(anchorNode) {
    let parentEl, childNode = anchorNode;

    if(childNode === null) {
      return null;
    }

    if(childNode.className && childNode.classList && childNode.classList.contains('react-editor-image-overlay')) {
      return childNode;
    }

    while(childNode.parentNode && childNode.parentNode.classList && !childNode.parentNode.classList.contains('react-editor-image-overlay')) {
      parentEl = childNode.parentNode;
      childNode = childNode.parentNode;
    }

    return parentEl || childNode;
  },

  isCommonAncestorContentEditable(commonAncestor) {
    let bool = false;

    if(commonAncestor.className !== undefined && commonAncestor.className.split(' ').indexOf('content-editable') !== -1) {
      bool = true;
    }

    return bool;
  },

  isAncestorOfContentEditable(node) {
    let bool = false;

    if(node === null) {
      return true;
    }

    for(let i = 0; i < node.childNodes.length; i++) {
      let child = node.childNodes[i];
      if(child.nodeType === 1 && child.classList && child.classList.contains('content-editable')) {
        bool = true
      }

      if(child.childNodes.length) {
        this.isAncestorOfContentEditable(child);
      }
    }

    return bool;
  },

  isImmediateChildOfContentEditable(node, CE) {
    let isChild = false;
    let children = [].slice.apply(CE.children);

    children.forEach(child => {
      if(Object.is(node, child)) {
        isChild = true;
      }
    });

    return isChild;
  },

  isChildOfCE(anchorNode) {
    let isChild = false;

    while(anchorNode.parentNode && anchorNode.nodeName !== 'body') {
      if(anchorNode.nodeType === 1 && anchorNode.classList.contains('box-content')) {
        break;
      }

      if(anchorNode.nodeType === 1 && anchorNode.classList.contains('content-editable')) {
        isChild = true;
      }
      anchorNode = anchorNode.parentNode;
    }

    return isChild;
  },

  findChildsDepthLevel(node, parentNode) {
    let depth = 0;
    let focusNode = node.parentNode === parentNode ? node : this.getRootParentElement(node);
    for(let i = 0; i < parentNode.childNodes.length; i++) {
      if(focusNode.isEqualNode(parentNode.childNodes[i])) {
        depth = i;
      }
    }
    return depth;
  },

  findDepthOf(anchorNode, parentNode) {
    let depth = 0, counter = 0, position = 0;
    let childNodes = [].slice.apply(parentNode.childNodes);
    let immediateParent;

    (function recurse(childNodes, counter, parent) {
      let child;
      counter += 1;

      if(childNodes.length < 1) {
        return;
      }

      for(let i = 0; i < childNodes.length; i++) {
        child = childNodes[i];

        if(Object.is(child, anchorNode)) {
          depth = counter;
          position = i;
          immediateParent = child.nodeType === 3 ? child.parentNode : child;
          break;
        }

        if(child.childNodes.length) {
          recurse(child.childNodes, counter, child);
        }
      }

    }(childNodes, 0, null));

    return {
      parent: immediateParent,
      position: position,
      depth: depth
    };
  },

  getRangesOfSelectedEl(el, range) {
    let indexes = {};
    let clone = range.cloneRange();
    clone.selectNodeContents(el);
    clone.setEnd(range.endContainer, range.endOffset);
    indexes.end = clone.toString().length;
    clone.setStart(range.startContainer, range.startOffset);
    indexes.start = indexes.end - clone.toString().length;
    return indexes;
  },

  getLiveNode(parent, clone) {
    let liveNode = null;
    domWalk(parent, child => {
      if(child.isEqualNode(clone)) {
        liveNode = child;
      }
    });
    return liveNode;
  },

  createULGroups(startContainer, endContainer, parentNode) {
    let groups = [], group = [], cont = false, child;

    for(let i = 0; i < parentNode.children.length; i++) {
      child = parentNode.children[i];

      if(child === startContainer || cont === true) {
        cont = true;

        if(child.nodeName !== 'DIV') {
          group.push(child);
        } else {
          groups.push(group);
          group = [];
        }
      }

      if(child === endContainer) {
        cont = false;
        groups.push(group);
        break;
      }
    }
    return groups;
  },

  createArrayOfDOMNodes(startContainer, endContainer, parentNode) {
    let array = [], cont = false, child, node;

    for(let i = 0; i < parentNode.children.length; i++) {
      child = parentNode.children[i];
      node = { hash: child.getAttribute('data-hash'), depth: i , nodeName: child.nodeName};

      if(child === startContainer || cont === true) {
        cont = true;
        array.push(node);
      }

      if(child === endContainer) {
        cont = false;
        break;
      }
    }

    return array;
  },

  findBlockNodeByHash(hash, parent, byPosition) {
    let node, fallbackNode;

    (function recurse(el) {
      let child;
      if(!el.children) {
        return;
      } else {
        for(let i = 0; i < el.children.length; i++) {
          child = el.children[i];

          if(child.getAttribute('data-hash') === hash) {
            node = child;
            return;
          }

          if(byPosition !== undefined && i === byPosition) {
            fallbackNode = child;
            return;
          }
          recurse(child);
        }
      }
    }(parent));
    return node || fallbackNode;
  },

  getParentOfCE(root) {
    let Editable = null;

    while(root.parentNode && !root.classList.contains('box')) {
      if(root.classList.contains('box-content')) {
        Editable = root;
      }

      root = root.parentNode;
    }
    return Editable;
  },

  getBlockElementsPreviousSibling(node, rootNode) {
    let prevSib = null;

    for(let i = 0; i <= rootNode.children.length; i++) {
      if(node === rootNode.children[i]) {
        prevSib = rootNode.children[i-1];
        break;
      }
    }

    return prevSib === undefined ? null : prevSib;
  },

  setCursorByNode(node) {
    let sel = rangy.getSelection();
    let range = rangy.createRangyRange();
    range.selectNodeContents(node);
    range.collapse(false);
    sel.setSingleRange(range);
  },

  getHashFromNode(node) {
    if(!node) { return node; }
    let hash;
    if(typeof node === 'string') {
      let search = 'data-hash="';
      let start = node.indexOf(search) + search.length;
      hash = node.substring(start, start+4);
    } else {
      hash = node.getAttribute('data-hash');
    }
    return hash;
  },

  isNodeInUL(node) {
    let isParentUL = false;
    let rootParent = this.getRootParentElement(node);

    while(node.parentNode) {
      if(node.localName === 'ul') {
        isParentUL = true;
        break;
      }

      if(node === rootParent) {
        break;
      }

      node = node.parentNode;
    }
    return isParentUL;
  },

  isULChildOfNode(node) {
    let isChildOf = false;

    for(let i = 0; i < node.childNodes.length; i++) {
      if(node.childNodes[i].localName === 'ul') {
        isChildOf = true;
      }
    }
    return isChildOf;
  },

  isChildOfCode(node) {
    let isChildOf = false;

    while(node.parentNode && node.parentNode.classList && !node.parentNode.classList.contains('content-editable')) {
      if(node.nodeName === 'CODE') {
        isChildOf = true;
      }
      node = node.parentNode;
    }

    return isChildOf;
  },

  getListItemFromTextNode(textNode) {
    let li;

    if(textNode.localName && textNode.localName === 'li') {
      return textNode;
    }

    while(textNode.parentNode) {
      if(textNode.parentNode.localName === 'li') {
        li = textNode.parentNode;
      }
      textNode = textNode.parentNode;
    }
    return li;
  },

  getListItemPositions(start, end, parent) {
    let positions = [], cont = false, child;
    let startContainer = this.getListItemFromTextNode(start);
    let endContainer = this.getListItemFromTextNode(end);

    for(let i = 0; i < parent.childNodes.length; i++) {
      child = parent.childNodes[i];
      if(startContainer === endContainer && startContainer === child) {
        positions.push(i);
        break;
      } else if(start === parent && parent.children.length === 1) {
        /** If theres only one item left in the list, Ranges will equal the parent element.  So we just want to pass index 0 here. */
        positions.push(i);
        break;
      }

      if(child === startContainer || cont == true) {
        cont = true;
        positions.push(i);
      }

      if(child === endContainer) {
        cont = false;
        break;
      }
    }
    return positions;
  },

  getAllNodesInSelection(start, end, parent) {
    let nodes = [],
        cont = false,
        child;

    for(let i = 0; i < parent.childNodes.length; i++) {
      child = parent.childNodes[i];

      if(child === start || cont === true) {
        cont = true;
        nodes.push(child);
      }

      if(child === end) {
        cont = false;
        break;
      }
    }

    return nodes;
  },

  isElementTypeInSelection(start, end, type) {
    let parentsChildren = [].slice.apply(start.parentNode.children);
    let hasType = false;
    let inBounds = false;

    /** If start or end containers are of type, we found a match. */
    if(start.nodeName === type || end.nodeName === type) {
      return true;
    }

    parentsChildren.forEach(child => {
      if(child === start) {
        inBounds = true;
      }

      if(child === end) {
        inBounds = false;
      }

      if(child.nodeName === type.toUpperCase() && inBounds) {
        hasType = true;
      }
    });

    return hasType;
  },

  isSelectionInAnchor(anchorNode) {
    let bool = false;

    while(anchorNode.parentNode && (anchorNode.parentNode.classList && !anchorNode.parentNode.classList.contains('content-editable'))) {
      if(anchorNode.nodeName === 'A') {
        bool = true;
        break;
      }

      anchorNode = anchorNode.parentNode;
    }

    return bool;
  },

  getAnchorNode(anchorNode) {
    let node;

    while(anchorNode.parentNode) {
      if(anchorNode.localName && anchorNode.localName === 'a') {
        node = anchorNode;
        break;
      }

      if(anchorNode.className && anchorNode.className.split(' ').indexOf('content-editable') !== -1) {
        break;
      }

      anchorNode = anchorNode.parentNode;
    }

    return node;
  },

  isNodeChildOfElement(node, elementName) {
    let isChildOf = false;

    while(node.parentNode && !node.parentNode.classList.contains('content-editable')) {
      if(node.nodeName === elementName) {
        isChildOf = true;
        break;
      }

      node = node.parentNode;
    }

    return isChildOf;
  },

  getParentNodeByElement(node, elementName) {
    let parent, childNodes = [];

    while(node.parentNode && !node.parentNode.classList.contains('content-editable')) {
      if(node.nodeName === elementName) {
        parent = node;
        break;
      }

      node = node.parentNode;
      childNodes.push(node.nodeName.toLowerCase());
    }

    return { parent: parent, childNodes: childNodes };
  },

  createNewNodeTree(nodeList, textContent) {
    let root = document.createElement(nodeList.pop());
    let newTree = (function recurse(list, root) {
      if(!list.length) {
        root.appendChild(document.createTextNode(textContent));
        return root;
      } else {
        root.appendChild(document.createElement(list.pop()));
        recurse(list, root.firstChild);
        return root;
      }
    }(nodeList, root));

    return newTree;
  },

  getTextNodeFromCarousel(div) {
    let textNode, figures, figure;

    figures = div.firstChild.children;
    figure = _.find(figures, function(fig) { return fig.classList.contains('show')});
    textNode = figure.firstChild.lastChild;

    if(textNode.nodeType !== 3) {
      textNode = textNode.childNodes[0];
    }

    return textNode !== undefined ? textNode : div;
  },

  getTextNodeFromVideo(div) {
    return div.firstChild.lastChild.firstChild.lastChild;
  },

  getLastTextNode(el) {
    let textNode, lastChild;

    /** Theres nothing of interest, just return the node. */
    if(!el.childNodes.length) {
      return el;
    }

    /** If there's no nested elements, we return the textNode of our element. */
    if(el.childNodes.length && el.childNodes[0].nodeType === 3) {
      return el.childNodes[0];
    }

    /**  Retrieve very last element. */
    lastChild = el.childNodes[el.childNodes.length-1];
    while(lastChild.lastChild) {
      lastChild = lastChild.lastChild;
    }

    /**
      * If lastChild is textNode.
      * Else if the first childNode is a text node, we have our result.
      * Else somehting went awry and the node has no text node to focus, so we create one.
     */
    if(lastChild.nodeType === 3) {
      textNode = lastChild;
    } else if(lastChild.childNodes.length && lastChild.childNodes[0].nodeType === 3) {
      textNode = lastChild.childNodes[0];
    } else {
      let text = document.createTextNode('');
      lastChild.appendChild(text);
      textNode = text;
    }

    return textNode;
  },

  getFirstTextNode(el) {
    let textNode, firstChild;

    if(!el.childNodes.length) {
      return el;
    }

    /** If there's no nested elements, we return the textNode of our element. */
    if(el.childNodes.length > 0 && el.childNodes[0].nodeType === 3) {
      return el.childNodes[0];
    }

    if(el.childNodes.length > 0) {
      firstChild = el.childNodes[0];
      if(firstChild.nodeType !== 3) {
        let text = document.createTextNode('');
        el.insertBefore(text, firstChild);
        firstChild = text;
      }
      textNode = firstChild.nodeType === 3 ? firstChild : firstChild.childNodes[0];

      while(textNode && textNode.childNodes.length > 0 && textNode.childNodes[0].nodeType !== 3) {
        textNode = textNode.childNodes[0];
      }
    }
    return textNode || firstChild;
  },

  getFigureFromNode(node) {
    let figure, found = false;

    while(node.parentNode && !found) {
      if(node.nodeName === 'FIGURE') {
        found = true;
        figure = node;
      }

      node = node.parentNode;
    }

    return figure;
  },

  createListOfActiveElements(anchorNode, parentNode) {
    let list = [];
    let map = {
      'B': 'bold',
      'STRONG': 'bold',
      'I': 'italic',
      'EM': 'italic',
      'A': 'anchor',
      'BLOCKQUOTE': 'blockquote',
      'PRE': 'pre',
      'CODE': 'code',
      'UL': 'ul'
    };

    while(anchorNode && !Object.is(anchorNode, parentNode) && anchorNode.parentNode !== undefined) {
      if(anchorNode.nodeType === 1 && map[anchorNode.nodeName]) {
        list.push(map[anchorNode.nodeName]);
      }
      anchorNode = anchorNode.parentNode;
    }

    return list;
  },

  removeBRTagsFromElement(el) {
    let child;

    for(let i = 0; i < el.children.length; i++) {
      child = el.children[i];
      if(child.nodeName === 'BR') {
        el.removeChild(child);
      }
    }
  },

  /**
   * Maintains immediate children of Content Editables.
   * 1) Makes sure children are block elements with hashes.
   * 2) Removes <br/> tags and/or wraps rogue text nodes.
   */
  maintainImmediateChildren(CE) {
    let blockEls = BlockElements;

    let P,
        children = [].slice.apply(CE.childNodes);

    children.forEach(child => {
      if(blockEls[child.nodeName]) {

        /** Removes empty span tags. */
        if(child.firstChild && child.childNodes.length) {
          let nodes = [].slice.apply(child.children);
          nodes.forEach(node => {
            if(node.nodeName === 'SPAN' && !node.textContent.length) {
              child.removeChild(node);
            }
          });
        }

        return; // Node is legit, boot out early.
      } else if(child.nodeName === 'BR') {
        CE.removeChild(child);
      } else if(!blockEls[child.nodeName] && child.nodeType === 1) {
        P = document.createElement('p');
        P.setAttribute('data-hash', hashids.encode(Math.floor(Math.random() * 9999 + 1)));
        // Copy nodes children over.
        if(child.hasChildNodes()) {
          P.appendChild(child.cloneNode(true));
        }
        CE.replaceChild(P, child);
      } else if(!blockEls[child.nodeName] && child.nodeType === 3) {
        P = document.createElement('p');
        P.setAttribute('data-hash', hashids.encode(Math.floor(Math.random() * 9999 + 1)));
        P.textContent = child.textContent;
        CE.replaceChild(P, child);
      } else {
        return;
      }
    });
  },

  /**
   * Maintains a specific line when the DOM is being mutated by the browser or execCommand.
   * We clean up adjacent tags and remove empty nested tags.
   */
  maintainImmediateNode(node) {
    let childNodes, self = this;
    (function recurse(node) {
      if(!node.childNodes && !node.childNodes.length) {
        return;
      } else {
        childNodes = [].slice.apply(node.childNodes);
        childNodes.forEach((child, index) => {

          /** Merges two nodes with the same nodeName. */
          if(index > 0 && child.previousSibling !== null && child.nodeName === child.previousSibling.nodeName
             && child.nodeName !== 'LI' && child.nodeName !== 'UL' && child.children && child.children.length < 1) {
            child.previousSibling.textContent += child.textContent;
            if(node.contains(child)) node.removeChild(child);
          }

          /** Remove BR & Empty tags. */
          if((child.nodeName === 'BR' && node.textContent.length > 0) ||
             (child.nodeName !== 'BR' && child.textContent.length < 1 && child.nodeName !== 'LI' && child.nodeName !== 'UL')) {
            if(node.contains(child)) node.removeChild(child);
          }

          /** Handles Chromes CE bug that adds span tags with inline styles.
            * We look for length > 2 because the styles we care about are much longer than that.
            * The length < 2 styles will be cleaned up by our Parser.
           */
          if(child.nodeName === 'SPAN' && child.style && child.style.length > 2 && child.previousSibling !== null) {
            child.previousSibling.innerHTML += child.innerHTML;
            if(node.contains(child)) node.removeChild(child);
          }

          recurse(child);
        });
      }
    }(node));
  },

  getListOfElements(node) {
    let elements = [];

    while(node.childNodes.length) {
      if(node.nodeType === 1) {
        elements.push(node.nodeName);
      }
      node = node.childNodes[0];
    }

    return elements;
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

  isChildOfParentByClass(child, parentClass) {
    let found = false;

    while(child.parentNode && !child.classList.contains('react-editor-wrapper')) {
      if(child.classList.contains('react-editor-wrapper')) {
        break;
      }

      if(child.classList.contains(parentClass)) {
        found = true;
      }

      child = child.parentNode;
    }

    return found;
  },

  hasValidUrl(string) {
    return string.split(' ').reduce((prev, curr) => {
      prev = Validator.isURL(curr.trim());
      return prev;
    }, false);
  },

  transformTextToAnchorTag(sel, range, setCursor) {
    /** Operate on current element's parent only, not the root parent. */
    let parentNode = range.startContainer.parentNode;
    if(!parentNode) { return; }

    let childNodes = [].slice.apply(parentNode.childNodes);
    childNodes.forEach(child => {
      if(child.nodeType === 3 && child.parentNode.nodeName !== 'A' && child.textContent.match(/(https?:\/\/(?:www\.|(?!www))[^\s\.]+\.[^\s]{2,}|www\.[^\s]+\.[^\s]{2,})/)) {
        let words = child.textContent.split(' ');
        let url = words.filter(word => { return Validator.isURL(word.trim()); })[0];

        if(!url) return;

        if(url && !Helpers.isUrlValid(url, 'video')) {
          let href = url;
          let oldRange = range.cloneRange();
          let index = child.textContent.indexOf(url);

          /** Prepend protocol if there isn't one. */
          if(!Validator.isURL(href, { require_protocol: true })) {
            href = 'http://' + href.trim();
          }
          /** Create Anchor. */
          let a = document.createElement('a');
          a.href = href;
          a.textContent = url;
          /** Replace the current text with our new anchor. */
          range.setStart(child, index);
          range.setEnd(child, index + url.length);
          range.deleteContents();
          range.insertNode(a);

          if(setCursor) {
            /** Sets range after the inserted anchor and appends a blank text node so we can latch on to it. */
            range.setStartAfter(a);
            let text = document.createTextNode(' ');
            range.insertNode(text);
            /** Grab the text node and set the range to it, thus placing our cursor. */
            range.selectNodeContents(text);
            range.setStartAndEnd(text, 0, 0);
            sel.setSingleRange(range);
          }
        }
      }
    });
  },

  /** http://stackoverflow.com/questions/6846230/coordinates-of-selected-text-in-browser-page - Tim Down */
  getSelectionCoords() {
    var sel = document.selection, range, rect;
    var x = 0, y = 0;
    if (sel) {
      if (sel.type != "Control") {
          range = sel.createRange();
          range.collapse(true);
          x = range.boundingLeft;
          y = range.boundingTop;
      }
    } else if (window.getSelection) {
      sel = window.getSelection();
      if (sel.rangeCount) {
        range = sel.getRangeAt(0).cloneRange();
        if (range.getClientRects) {
          range.collapse(true);
          if (range.getClientRects().length>0) {
            rect = range.getClientRects()[0];
            x = rect.left;
            y = rect.top;
          }
        }
        // Fall back to inserting a temporary element
        if (x == 0 && y == 0) {
          var span = document.createElement("span");
          if (span.getClientRects) {
            // Ensure span has dimensions and position by
            // adding a zero-width space character
            span.appendChild( document.createTextNode("\u200b") );
            range.insertNode(span);
            rect = span.getClientRects()[0];
            x = rect.left;
            y = rect.top;
            var spanParent = span.parentNode;
            spanParent.removeChild(span);

            // Glue any broken text nodes back together
            spanParent.normalize();
          }
        }
      }
    }
    return { x: x, y: y };
  },
  /** http://stackoverflow.com/questions/12920225/text-selection-in-divcontenteditable-when-double-click - Tim Down */
  getMouseEventCaretRange(evt) {
    var range, x = evt.clientX, y = evt.clientY;

    // Try the simple IE way first
    if (document.body.createTextRange) {
        range = document.body.createTextRange();
        range.moveToPoint(x, y);
    }

    else if (typeof document.createRange != "undefined") {
        // Try Mozilla's rangeOffset and rangeParent properties,
        // which are exactly what we want
        if (typeof evt.rangeParent != "undefined") {
            range = document.createRange();
            range.setStart(evt.rangeParent, evt.rangeOffset);
            range.collapse(true);
        }

        // Try the standards-based way next
        else if (document.caretPositionFromPoint) {
            var pos = document.caretPositionFromPoint(x, y);
            range = document.createRange();
            range.setStart(pos.offsetNode, pos.offset);
            range.collapse(true);
        }

        // Next, the WebKit way
        else if (document.caretRangeFromPoint) {
            range = document.caretRangeFromPoint(x, y);
        }
    }
    return range;
  },

  /**
   * Description and OnPaste Parser.
   */

  parseDescription(html) {
    return new Promise((resolve, reject) => {
      let handler = new DomHandler((err, dom) => {
        if(err) reject(err);
        let clean = this.createContainers(dom);
        this.convertVideoSrc(clean, result => {
          result = result.filter(item => { return item !== null; });

          let parsedHTML = this.mergeAndParseTree(result);
          resolve(parsedHTML);
        });
      }, {});

      let parser = new HtmlParser.Parser(handler, { decodeEntities: true });
      parser.write(html);
      parser.done();
    });
  },

  convertVideoSrc(map, mainCallback) {
    async.map(map, (item, callback) => {
      if(item.type === 'Video' && item.video[0].type == 'iframe') {
        let videoData = Helpers.getVideoData(item.video[0].embed);
        if(!videoData) {
          return callback(null, null);
        }
        item.video[0] = Object.assign({}, videoData, item.video[0]);
        return callback(null, item);
      } else {
        return callback(null, item);
      }
    }, (err, result) => {
      if(err) { return err; }
      mainCallback(result);
    });
  },

  findImageWrapper(element) {
    let imgWrapper;

    (function recurse(el){
      if(!el.children) {
        return el;
      } else {
        el.children.forEach(child => {
          if(child.name === 'div' && child.attribs.class && child.attribs.class.indexOf('react-editor-image-wrapper') !== -1) {
            imgWrapper = child;
          }
          recurse(child);
        });
      }
    } (element));

    return imgWrapper;
  },

  createContainers(html) {
    let tree = html.map((el, index) => {
      let mediaData, carousel, video, newEl;
      /** If top element is a carousel widget or video, we create the markup for those elements.
        * Else if the top element is a image, create a Carousel.
        * Else, recurse through the element.
        *     If theres images in the element, we're going to convert it to a Carousel.
        *     Else return the processed tree.
       */
      if(el.name === 'div' && el.attribs.class && el.attribs.class.indexOf('embed-frame') !== -1) {
        if(el.attribs['data-type'] === 'widget' && el.children && el.children[0].attribs.class.indexOf('image_widget') !== -1) {
          /** Handle Carousel */
          mediaData = this.getCarouselData(el);
          newEl = this.createCarousel(mediaData);
          return newEl;
        } else if(el.attribs['data-type'] === 'video') {
          /** Primarily for mp4. */
          mediaData = this.getVideoData(el);
          newEl = this.createVideo(mediaData);
          return newEl;
        } else if(el.attribs['data-type'] === 'url') {
          /** Handle Video, Image & Repo as URL Widgets. */
          mediaData = this.getURLWidgetData(el);

          /** Repo gets transformed into a placeholder. */
          if(mediaData[0].type === 'repo') {
            newEl = this.createWidgetPlaceholder(mediaData[0]);
          } else {
            newEl = this.createVideo(mediaData);
          }

          return newEl;
        } else if(el.attribs['data-type'] === 'file') {
          /** Handle File */
          mediaData = this.getFileData(el);
          /** If file has no id or url, remove it. */
          if(!mediaData.url || !mediaData.id) {
            newEl = null;
          } else {
            newEl = this.createFile(mediaData);
          }
          return newEl;
        } else if(el.attribs['data-type'] === 'widget') {
          if(el.children && el.children[0].attribs.class.indexOf('old_code_widget') !== -1) {
            /** Handle Old Code Widget */
            mediaData = this.getWidgetPlaceholderData(el);
            newEl = this.createWidgetPlaceholder(mediaData);
          } else if(el.children && el.children[0].attribs.class.indexOf('parts_widget') !== -1) {
            mediaData = this.getWidgetPlaceholderData(el);
            newEl = this.createWidgetPlaceholder(mediaData);
          }
          return newEl;
        } else {
          return null;
        }
      } else if(el.name === 'img') {
        /** Handle Carousel */
        mediaData = [{ url: el.attribs.src, alt: el.attribs.alt || '' }];
        newEl = this.createCarousel(mediaData);
        return newEl;
      } else {
        let data = this.recurseElement(el);
        if(data.mediaType) {
          /** Handle Carousel */
          mediaData = this.getImages(data.el);
          newEl = this.createCarousel(mediaData);
          return [newEl, { type: 'CE', json: [data.el], hash: hashids.encode(Math.floor(Math.random() * 9999 + 1)) }];
        } else {
          return {
            type: 'CE',
            json: [data.el]
          };
        }
      }

    }).
    filter(item => {
      return item !== null;
    }).
    reduce((acc, curr) => {
      if(Array.isArray(curr)) {
        acc = acc.concat(curr);
      } else {
        acc.push(curr);
      }
      return acc;
    }, []);

    return tree;
  },

  recurseElement(element) {
    let mediaType = false;
    let blockEls = {
      'div': true,
      'p': true,
      'ul': true,
      'blockquote': true,
      'pre': true,
      'h3': true
    };
    let el = (function recurse(el, depth) {
      let child;

      if(!el.children) {
        return el;
      }

      for(let i = el.children.length; i > 0; i--) {
        child = el.children[i-1];

        /** Remove script tags */
        if(child.type === 'script' || child.name === 'script') {
          child.parent.children.splice(i-1, 1);
        }

        /** Flag an image */
        if(child.name === 'img') {
          mediaType = 'image';
        }

        /** Force unlinked anchors to ems. */
        if(child.name === 'a' && !Validator.isURL(child.attribs.href)) {
          child.name = 'em';
        }
        /** If child has no name, its likely a text node or comment.  Force these to spans and add an attribs object. */
        if(child.name === undefined) {
          child.name = 'span';
          child.attribs = child.attribs || {};
        }

        /** Transform any nested block element to a span, maintain top level element as a block. */
        if(blockEls[child.name] && depth !== 0) {
          child.name = 'span';
        } else if(child.name === 'div' && depth === 0) {
          child.name = 'p';
        }

        if(child.children && child.children.length > 0) {
          /** Recursion */
          recurse(child, depth+1);
          if(child.children.length < 1) {
            child.parent.children.splice(i-1, 1);
          }
        } else {
          if(!child.data && child.name !== 'img' && (child.attribs['data-type'] && child.attribs['data-type'] !== 'url')) {  // Node has no content.
            child.parent.children.splice(i-1, 1);
          }
        }
      }
      return el;
    }(element, 0));

    return {
      mediaType: mediaType,
      el: el
    };
  },

  getURLWidgetData(element) {
    let src, figcaption, type, widgetType;

    (function recurse(el) {
      if(!el.children) {
        return el;
      } else {
        /** Get the url from the root element. */
        if(el.attribs.class && el.attribs.class.indexOf('embed-frame') !== -1 && el.attribs['data-type'] === 'url') {
          src = el.attribs['data-url'];
          type = 'iframe';
        }

        el.children.forEach(child => {
          /** Sets type to image. */
          if(child.attribs && child.attribs.class && child.attribs.class.indexOf('embed-img') !== -1) {
            type = 'image';
          }

          /** Get the video url from the iframe attribute rather than the embed url. */
          if(child.name === 'iframe' && child.attribs.src) {
            src = child.attribs.src;
          }

          /** Gets code repo url widgets */
          if(child.attribs && child.attribs['data-repo']) {
            type = 'repo';
            widgetType = child.attribs.class;
          }

          /** Grabs video figcaptions. */
          if(child.name === 'div' && child.attribs.class && child.attribs.class.indexOf('embed-figcaption') !== -1) {
            figcaption = child.children.length ? child.children[0].data : '';
          }

          recurse(child);
        });
      }

    }(element));

    return [{
      embed: src,
      figcaption: figcaption || '',
      type: type || '',
      widgetType: widgetType || ''
    }];
  },

  getCarouselData(element) {
    let images = [];
    let carouselData = [];

    (function recurse(el) {
      if(!el.children) {
        return el;
      } else {
        el.children.forEach(child => {
          if(child.name === 'div' && child.attribs && child.attribs.class
             && child.attribs.class.indexOf('image') !== -1 && child.attribs['data-file-id']) {
            images.push(child);
          }
          recurse(child);
        });
      }
    }(element));

    images.forEach(image => {
      let obj = {};
      obj.id = image.attribs['data-file-id'] || null;

      (function recurse(i) {
        if(!i.children) {
          return i;
        } else {
          i.children.forEach(child => {
            if(child.name === 'img') {
              obj.url = child.attribs.src;
              obj.alt = child.attribs.alt;
              obj.show = false;
            }

            if(child.name === 'figcaption') {
              obj.figcaption = child.attribs['data-value'] || '';
            }
            recurse(child);
          });
        }
      }(image));

      carouselData.push(obj);
    });

    return carouselData;
  },

  getImages(element) {
    let images = [];

    (function recurse(el) {
      let obj = {};
      if(!el.children) {
        return el;
      } else {
        el.children.forEach(child => {
          if(child.name === 'img') {
            /** If the embed image widget is nested in another element, get the id from the third parent up. */
            if(child.parent && child.parent.parent && child.parent.parent.parent && child.parent.parent.parent.attribs['data-file-id']) {
              obj.id = child.parent.parent.parent.attribs['data-file-id'];
            }
            obj.url = child.attribs.src;
            obj.alt = child.attribs.alt || '';
            obj.figcaption = '';
            obj.show = false;
            images.push(obj);
          }
          recurse(child);
        });
      }
    }(element));

    return images;
  },

  getFileData(element) {
    let url, content,
        id = element.attribs['data-file-id'],
        caption = element.attribs['data-caption'] || '';

    (function recurse(el) {
      if(!el.children) {
        return el;
      } else {
        el.children.forEach(child => {
          if(child.name === 'a') {
            url = child.attribs.href;
            content = child.children[0].data
          }
          recurse(child);
        });
      }
    }(element));

    return { id: id, caption: caption, url: url, content: content };
  },

  getVideoData(element) {
    let src, figcaption;

    (function recurse(el) {
      if(!el.children) {
        return el;
      } else {
        /** Get the url from the root element. */
        if(el.attribs.class && el.attribs.class.indexOf('embed-frame') !== -1 && el.attribs['data-type'] === 'url') {
          src = el.attribs['data-url'];
        }

        el.children.forEach(child => {
          /** Get the video src from the source tag if it wasn't supplied in the parent. */
          if(src === undefined && child.name === 'source') {
            src = child.attribs['src'];
          }

          /** Grabs video figcaptions. */
          if(child.name === 'div' && child.attribs.class && child.attribs.class.indexOf('embed-figcaption') !== -1) {
            figcaption = child.children.length ? child.children[0].data : '';
          }

          recurse(child);
        });
      }

    }(element));

    return [{
      embed: src,
      figcaption: figcaption || '',
      service: 'mp4',
      type: ''
    }]
  },

  getWidgetPlaceholderData(el) {
    let id, widgetType;

    id = el.attribs['data-widget-id'];
    widgetType = el.children[0].attribs.class.split(' ').pop();

    return {
      id: id,
      type: 'widget',
      widgetType: widgetType
    };
  },

  createModel(data) {
    return {
      attribs: data.attribs,
      children: data.children,
      content: data.content,
      name: data.name
    }
  },

  createCarousel(images) {
    if(!images.length) { return null; }

    images[0].show = true;
    return {
      type: 'Carousel',
      images: images,
      hash: hashids.encode(Math.floor(Math.random() * 9999 + 1))
    };
  },

  createVideo(video) {
    return {
      type: 'Video',
      video: video,
      hash: hashids.encode(Math.floor(Math.random() * 9999 + 1))
    };
  },

  createFile(data) {
    return {
      type: 'File',
      data: data,
      hash: hashids.encode(Math.floor(Math.random() * 9999 + 1))
    }
  },

  createCodeBlock(data) {
    let pre = this.recurseAndReturnEl(data, 'pre');
    let PRE = {
      ...pre,
      children: [{
        name: 'code',
        children: pre.children,
        attribs: {},
        type: 'tag'
      }]
    };
    return {
      type: 'CE',
      json: [PRE]
    };
  },

  createWidgetPlaceholder(data) {
    return {
      type: 'WidgetPlaceholder',
      data: data,
      hash: hashids.encode(Math.floor(Math.random() * 9999 + 1))
    }
  },

  recurseAndReturnEl(parentEl, elName) {
    var el;

    (function recurse(parentEl) {
      if(!parentEl.children) {
        return parentEl;
      } else {
        parentEl.children.forEach(child => {
          if(child.name === elName) {
            el = child;
            return;
          }
          recurse(child);
        });
      }
    }(parentEl));

    return el;
  },

  mergeAndParseTree(collection) {
    let newCollection = [];

    collection.forEach((component, index) => {
      if(index > 0 && collection[index-1].type === 'CE' && component.type === 'CE') {
        newCollection[newCollection.length-1].json.push(...component.json);
      } else {
        newCollection.push(component);
      }
    });

    newCollection = newCollection.map(coll => {
      if(coll.type === 'CE') {
        coll.hash = hashids.encode(Math.floor(Math.random() * 9999 + 1));
        coll.json = this.parseTree(coll.json);
        coll.json = this.cleanTree(coll.json);
        return coll;
      } else {
        return coll;
      }
    })
    .filter(coll => {
      if(coll.type === 'CE' && !coll.json.length) {
        return false;
      } else {
        return true;
      }
    });

    /** Makes sure theres always a CE at the end. */
    if(newCollection[newCollection.length-1] && newCollection[newCollection.length-1].type !== 'CE') {
      newCollection.push({
        type: 'CE',
        json: [{
          tag: 'p',
          attribs: {},
          children: [],
          content: null
        }],
        hash: hashids.encode(Math.floor(Math.random() * 9999 + 1))
      });
    }

    return newCollection;
  },

  parseTree(html) {
    function handler(html, depth) {
      return _.map(html, (item) => {
        let name;

        /** Remove these nodes immediately. */
        if(item.name === 'script' || item.name === 'comment' || item.name === 'meta') {
          return null;
        } else if(item.name === 'br' && depth > 1) {
          return null;
        }

        /** Transform tags to whitelist. */
        item.name = this.transformTagNames(item);
        if(!ElementWhiteList[item.name]) {
          item.name = depth > 0 ? 'span' : 'p';
        }

        /** Remove invalid anchors. */
        if(item.name === 'a' && !Validator.isURL(item.attribs.href)) {
          return null;
        }

        /** Removes styles. */
        if(item.attribs && item.attribs.style) {
          item.attribs.style = '';
        }
        /** Removes classes. */
        if (item.attribs && item.attribs.class) {
          item.attribs.class = '';
        }

        if(item.type === 'text' && !item.children) {
          if(item.data.match(/&nbsp;/g)) {
            item.data = item.data.replace(/&nbsp;/g, ' ');
          }

          return {
            tag: 'span',
            content: sanitizer.escape(item.data),
            attribs: {},
            children: []
          };
        } else if(item.children && item.children.length === 1 && item.children[0].type === 'text') {
          if(item.children[0].data.match(/&nbsp;/g)) {
            item.children[0].data = item.children[0].data.replace(/&nbsp;/g, ' ');
          }
          return {
            tag: name || item.name,
            content: sanitizer.escape(item.children[0].data),
            attribs: item.attribs,
            children: []
          };
        } else {
          return {
            tag: name || item.name,
            content: null,
            attribs: item.attribs,
            children: handler.apply(this, [item.children || [], depth+1])
          }
        }
      }).filter(item => { return item !== null; });
    }
    return handler.call(this, html, 0);
  },

  transformTagNames(node) {
    let nodeName = node.name;

    let converter = {
      'b': 'strong',
      'bold': 'strong',
      'italic': 'em',
      'i': 'em',
      'ol': 'ul',
      'h1': 'h3',
      'h2': 'h3',
      'h4': 'h3'
    };

    return converter[nodeName] || nodeName;
  },

  cleanTree(json) {
    return json.map(item => {
      if(item.tag === 'li') {
        item.tag = 'ul';
        item.children = [{
          tag: 'li',
          content: item.content,
          attribs: {},
          children: []
        }];
        item.content = null;

        /** Removes empty li's nested or not */
        item = this.cleanUL(item);

        /** We do this last because cleanUL will dive in recursively and remove all empty tags including the li we just added. */
        if(!item.content || !item.children.length) {
          item = null;
        }

        return item;
      } else if(item.tag === 'ul') {
        if(!item.children.length && item.content.length > 0) {
          item.children.push({
            tag: 'li',
            attribs: {},
            children: [],
            content: item.content
          });
          item.content = '';
        }

        item.children = item.children.map(child => {
          if(child.children && !child.children.length && child.content && child.content.length <= 1 && (child.content === '\n' || child.content === ' ')) {
            return null;
          } else if(child.tag !== 'li') {
            child.tag = 'li';
            return child
          } else {
            return child;
          }
        }).filter(child => { return child !== null; });

        /** Removes empty li's nested or not */
        item = this.cleanUL(item);
        return item;
      } else if(item.tag === 'div') {
        item.tag = 'p';

        if(item.children.length < 1) {
          item.children.push({
            tag: 'br',
            content: '',
            attribs: {},
            children: []
          });
        }

        return item;
      } else if(item.tag === 'span') {
        if(item.content && item.content === '\n' || item.content === ' ') {
          return null;
        } else {
          item.tag = 'p';

          if(item.children.length < 1) {
            item.children.push({
              tag: 'br',
              content: '',
              attribs: {},
              children: []
            });
          }

          return item;
        }
      } else if(item.tag === 'br') {
        return null;
      } else if(!BlockElements[item.tag.toUpperCase()]) {
        /** Catches other inlines and wraps the item in a parapraph. */
        let p = {
          tag: 'p',
          content: '',
          attribs: {},
          children: [ item ]
        };
        return p;
      } else if(item.tag === 'p' && item.children && item.children.length < 1) {
        /** Remove any carriage returns and get rid of the element if it's then empty. */
        if(item.content && item.content.match(/\n/)) {
          item.content = item.content.replace(/\n/g, '');
        }
        if(item.content && !item.content.length) {
          item = null;
        }
        if(item.content === null && !item.children.length) {
          item = null;
        }
        return item;
      } else if( (item.children === null || !item.children.length) && (item.content === null || !item.content.length) ) {
        return null;
      } else {
        return item;
      }
    }).filter(c => { return c !== null; });
  },

  cleanUL(ul) {
    let newChildren = (function recurse(children) {
      if(!children.length) {
        return children;
      } else {
        return children.map(child => {
          if(!child.children.length && (!child.content || child.content.match(/^[\u21B5|\s+]{1}$/) !== null)) {
            return null;
          } else {
            child.children = recurse(child.children);

            if(!child.children.length && (!child.content || child.content.match(/^[\u21B5|\s+]{1}$/) !== null)) {
              child = null;
            }

            return child;
          }
        }).filter(child => { return child !== null; });
      }
    }(ul.children));

    ul.children = newChildren;
    return ul;
  }

};

export default Utils;