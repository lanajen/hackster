import _ from 'lodash';
import rangy from 'rangy';
import { domWalk, treeWalk } from '../utils/Traversal';

export default {

  removeInline(parent, range, element) {
    if(parent.nodeName === 'UL') {
      let selectedNodes = range.getNodes([3]);
      let tree;

      selectedNodes.forEach(item => {
        tree = domWalk(parent, child => {
          if(child.isEqualNode(item)) {
            /** If the element is nested in other inlines, get that parent wrapper.  Else take the text. */
            let replacement = child.parentNode.nodeName.toLowerCase() === element ? child : child.parentNode;
            while(child.parentNode) {
              if(child.nodeName.toLowerCase() === element) {
                child.parentNode.replaceChild(replacement, child);
                break;
              }
              child = child.parentNode;
            }
          }
        });
      });
      return tree;
    } else {
      let start = range.startContainer;
      return domWalk(parent, child => {
        if(child.isEqualNode(start)) {
          while(child.parentNode) {
            if(child.nodeName.toLowerCase() === element) {
              child.parentNode.replaceChild(document.createTextNode(child.textContent), child);
              break;
            }
            child = child.parentNode;
          }
        }
      });
    }
  },

  transformInline(parent, range, depth, element) {
    if(parent.nodeName === 'UL') {
      let selectedNodes = range.getNodes([3]);
      let fragment = range.cloneContents();
      let frags = this.createFragmentArray([].slice.apply(fragment.childNodes));
      parent = parent.cloneNode(true);
      let tree;

      selectedNodes.forEach((node, index) => {
        let frag = frags[index];
        let position = index === 0 ? 'start' : index === selectedNodes.length-1 ? 'end' : 'middle';
        tree = domWalk(parent, (child, root) => {
          if(node.isEqualNode(child)) {
            let { start, middle, end } = this.createTextContent(child, frag, range, position);
            let startChild = child.cloneNode();
            let middleChild = document.createElement(element);
            let endChild = child.cloneNode();
            startChild.textContent = start;
            middleChild.textContent = middle;
            endChild.textContent = end;
            root.replaceChild(startChild, child);
            root.appendChild(middleChild);
            root.appendChild(endChild);
          }
        });
      });
      return tree;
    } else {
      let element = document.createElement('code');
      element.appendChild(range.cloneContents());
      range.deleteContents();
      range.insertNode(element);

      range.selectNode(element);
      range.collapse(false);
      let sel = rangy.getSelection();
      sel.setSingleRange(range);
      return parent;
    }
  },

  createElementArray(node, parent) {
    let elements = [];

    while(node.parentNode && !node.isEqualNode(parent)) {
      if(node.nodeType === 1) {
        elements.push(node.nodeName.toLowerCase());
      }
      node = node.parentNode;
    }

    return elements;
  },

  createFragmentArray(array) {
    let fragments = array.map(fragment => {
      if(fragment.nodeType === 1) {
        let c = [].slice.apply(fragment.childNodes);
        return c.map(child => {
          if(child.nodeType === 3) {
            return child;
          } else {
            return this.createFragmentArray([].slice.apply(child.childNodes));
          }
        });
      } else {
        return fragment;
      }
    });
    return _.flattenDeep(fragments);
  },

  createTextContent(child, frag, range, position) {
    let index = position === 'start' ? range.startOffset: position === 'end' ? 0 : child.textContent.indexOf(frag.textContent);
    return {
      start: child.textContent.slice(0, index),
      middle: child.textContent.slice(index, index + frag.textContent.length),
      end: child.textContent.slice(index + frag.textContent.length)
    };
  },

  replaceChild(child, replacement) {
    let parent = child.parent;
    let index = parent.children.indexOf(child);

    parent.children.splice(index, 1, replacement);
    return parent;
  },

  findIndexOfChild(parent, child) {
    let index = -1;

    parent.children.forEach((item, i) => {
      if(Object.is(child, item)) {
        index = i;
      }
    });

    return index;
  }
}