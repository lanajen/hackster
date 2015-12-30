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
        if(depth === 0) { callback(root, root, depth); }
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

}