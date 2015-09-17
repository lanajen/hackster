import rangy from 'rangy';
import _ from 'lodash';
import HtmlParser from 'htmlparser2';
import DomHandler from 'domhandler';

const Utils = {

  getSelectionData() {
    let sel = rangy.getSelection(),
        range = sel.getRangeAt(0),
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
  },

  /**
   * Gets the block level element of the current tree dictated by a Selection object.
   * @param  {[textNodeValue]} [window.getSelection().anchorNode]
   * @return {[DOM Node]} [Parent element directly under contenteditable div.]
   */
  getRootParentElement(anchorNode) {
    let parentEl, childNode = anchorNode;

    if(anchorNode.className && anchorNode.className.split(' ').indexOf('content-editable') === 1) {
      return anchorNode;
    }

    while(childNode.parentNode && childNode.parentNode.className !== undefined 
          && childNode.parentNode.className.split(' ').indexOf('content-editable') !== 1) {
      parentEl = childNode.parentNode;
      childNode = childNode.parentNode;
    }

    return parentEl = parentEl === undefined ? childNode : parentEl;
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

    if(commonAncestor.className !== undefined && commonAncestor.className.split(' ').indexOf('content-editable') === 1) {
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
      if(child.nodeType === 1 && child.classList.contains('content-editable')) {
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
    let node;
    let fallbackNode;
    
    for(let i = 0; i < parent.children.length; i++) {
      if(parent.children[i].getAttribute('data-hash') === hash) {
        node = parent.children[i];
      }

      if(i === byPosition) {
        fallbackNode = parent.children[i];
      }
    }

    return node || fallbackNode;
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

  getListItemPositions(startContainer, endContainer, parent) {
    let positions = [], cont = false, child;
    startContainer = this.getListItemFromTextNode(startContainer);
    endContainer = this.getListItemFromTextNode(endContainer);

    for(let i = 0; i < parent.childNodes.length; i++) {
      child = parent.childNodes[i];

      if(startContainer === endContainer && startContainer === child) {
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

  isSelectionInAnchor(anchorNode) {
    let bool = false;

    while(anchorNode.parentNode) {
      if(anchorNode.localName && anchorNode.localName === 'a') {
        bool = true;
        break;
      }

      if(anchorNode.className && anchorNode.className.split(' ').indexOf('content-editable') === 1) {
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

      if(anchorNode.className && anchorNode.className.split(' ').indexOf('content-editable') === 1) {
        break;
      }

      anchorNode = anchorNode.parentNode;
    }

    return node;
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
    if(el.childNodes.length > 0 && el.childNodes[0].nodeType === 3) {
      return el.childNodes[0];
    }

    if(el.childNodes.length > 0) {
      lastChild = el.lastChild;
      textNode = lastChild.childNodes[0];

      while(textNode && textNode.childNodes.length && textNode.childNodes[0].nodeType !== 3) {
        textNode = textNode.childNodes[0];
      }

    }

    return textNode || el;
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
      'UL': 'ul'
    };

    while(!Object.is(anchorNode, parentNode) && anchorNode.parentNode !== undefined) {
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

  removeEmptyTags(el) {
    (function recurse(parent) {
      let children = parent.childNodes,
          child, i = 0;

      if(!children.length) { return; }

      for(i = 0; i <= children.length; i++) {
        let child = children[i];
        /** Since we're removing things from children recursively, the index will change if was removed from the DOM. */
        if(child === undefined) {
          child = children[i-1];
        }

        if(child === undefined) { return; }
        recurse(child);

        if(child.nodeName === 'BR' || child.textContent.length < 1) {
          parent.removeChild(child);
        }

      }
    }(el, null));
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

  parseDescription(html) {
    return new Promise((resolve, reject) => {
      let handler = new DomHandler((err, dom) => {
        if(err) reject(err);

        let parsedHTML = this.parseTree(dom);
        resolve(parsedHTML);
      }, {});

      let parser = new HtmlParser.Parser(handler, { decodeEntities: true });
      parser.write(html);
      parser.done();
    });
  },

  parseTree(html) {
    function handler(html) {
      return _.map(html, function(item) {
        let name;
        if(item.name) {
          name = this.transformTagNames(item);
        }

        if(item.type === 'text' && !item.children) {
          if(item.data.match(/&nbsp;/g)) {
            item.data = item.data.replace(/&nbsp;/g, ' ');
          }

          return {
            tag: 'span',
            content: item.data,
            attribs: {},
            children: []
          };
        } else if(item.children && item.children.length === 1 && item.children[0].type === 'text') {
          if(item.children[0].data.match(/&nbsp;/g)) {
            item.children[0].data = item.children[0].data.replace(/&nbsp;/g, ' ');
          }
          return {
            tag: name || item.name,
            content: item.children[0].data,
            attribs: item.attribs,
            children: []
          };
        } else {
          return {
            tag: name || item.name,
            content: null,
            attribs: item.attribs,
            children: handler.apply(this, [item.children || []])
          }
        }
      }.bind(this));
    }
    return handler.call(this, html);
  },

  transformTagNames(node) {
    let nodeName = node.name;

    if(node.name === 'div' && node.attribs['data-type']) {
      nodeName = node.attribs['data-type'];
    }

    let converter = {
      'b': 'strong',
      'bold': 'strong',
      'i': 'em',
      'italic': 'em',
      'carousel': 'carousel',
      'video': 'video'
    };

    return converter[nodeName] || nodeName;
  },

};

export default Utils;