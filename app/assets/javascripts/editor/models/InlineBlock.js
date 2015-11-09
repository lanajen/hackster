import _ from 'lodash';
import { domWalk, treeWalk } from '../utils/Traversal';

export default {

  removeInline(parent, range, element) {
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
  },

  transformInline(parent, range, element) {
    let selectedNodes = range.getNodes([3]);
    let fragment = range.cloneContents();
    let frags = this.createFragmentArray([].slice.apply(fragment.childNodes));
    let tree;

    selectedNodes.forEach((node, index) => {
      let frag = frags[index];
      tree = domWalk(parent, child => {
        if(node.isEqualNode(child)) {
          let { start, middle, end } = this.createTextContent(child, frag, range);
          let middleChild = document.createElement(element);
          let endChild = child.cloneNode();
          child.textContent = start;
          middleChild.textContent = middle;
          endChild.textContent = end;
          child.parentNode.appendChild(middleChild);
          child.parentNode.appendChild(endChild);
        }
      });
    });
    return tree;
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

  createTextContent(child, frag, range) {
    let index = child.textContent.indexOf(frag.textContent);
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