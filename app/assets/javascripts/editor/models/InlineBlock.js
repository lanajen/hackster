import _ from 'lodash';

export default {

  domWalk(tree, callback) {
    (function recurse(root, depth) {
      if(!root.childNodes.length) {
        return root;
      } else {
        let childNodes = [].slice.apply(root.childNodes);
        childNodes.forEach(child => {
          callback(child, root, depth);
          recurse(child, depth+1);
        });
      }
    }(tree, 0));
    return tree;
  },

  treeWalk(json, callback) {
    (function recurse(root, depth) {
      if(!root.children.length) {
        callback(root, root, depth);
        return root;
      } else {
        root.children.forEach(child => {
          callback(child, root, depth);
          recurse(child, depth+1);
        });
      }
    }(json[0], 0));
    return json;
  },

  removeInline(parent, range, element) {
    let selectedNodes = range.getNodes([3]);
    let tree;

    selectedNodes.forEach(item => {
      tree = this.domWalk(parent, child => {
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
    let fragments = range.cloneContents();
    let mapped = this.createNodeMap(parent, selectedNodes, fragments);
    let tree;
    // console.log('M', mapped, selectedNodes, fragments);
    mapped.forEach(item => {
      tree = this.domWalk(parent, child => {
        if(child.isEqualNode(item.node)) {
          let replacement = document.createElement(element);
          replacement.appendChild(document.createTextNode(item.fragment || item.node.data));

          if(child.nodeType === 3) {
            if(child.parentNode.nodeName === 'SPAN') {
              child.parentNode.parentNode.replaceChild(replacement, child.parentNode);
            } else {
              child.parentNode.replaceChild(replacement, child);
            }
          } else {
            child.removeChild(child.childNodes[0]);
            child.appendChild(replacement);
          }
        }
      });
    });

    return tree;
  },

  createNodeMap(parent, selectedNodes, fragment) {
    let map = [],
        obj = {};

    this.domWalk(parent, (child, root, depth) => {
      selectedNodes.forEach(node => {
        if(node.isEqualNode(child)) {
          obj = {
            node: child,
            depth: depth,
            fragment: this.getFragmentText(fragment, node)
          };
          map.push(obj);
        }
      });
    });
    return map;
  },

  getFragmentText(fragment, node) {
    let text;
    this.domWalk(fragment, child => {
      if(child.isEqualNode(node)) {
        text = child.data;
        return;
      }
    });
    return text;
  },

  cleanJson(json) {
    json = this.treeWalk(json, (child, root, depth) => {
      if(root.children.length) {
        root.children = this.normalize(root.children);
      }

      if(child.tag === 'span' && child.content === '' && child.children.length === 1) {
        let index = this.findIndexOfChild(root, child);
        root.children.splice(index, 1, child.children[0]);
      }
    });
    return json;
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
  },

  normalize(children) {
    return children.reduce((prev, curr, idx) => {
      if(prev.length > 0 && prev[prev.length-1].tag === curr.tag) {
        prev[prev.length-1] = Object.assign({}, prev[prev.length-1], curr);
        return prev;
      } else {
        return prev.concat(curr);
      }
    }, []);
  },

  createElement(tag, content) {
    return {
      attribs: {},
      children: [],
      content: content,
      tag: tag
    };
  }
}