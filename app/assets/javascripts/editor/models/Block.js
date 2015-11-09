import _ from 'lodash';
import { domWalk, treeWalk } from '../utils/Traversal';
import Utils from '../utils/DOMUtils';

export default {

  getTextContent(json) {
    let text = '';

    treeWalk(json, child => {
      if(child.content) {
        text += child.content;
      }
    });

    return text;
  },

  splitTextAtSelection(range, anchorNode, parentNode) {
    /** Builds the selected text from scratch honoring all wrapped node types.  We delete the selection in the Promise handler. */
    let selectedHtml = range.toHtml();
    let selectedBuild = Utils.getParentNodeByElement(anchorNode, 'P');
    let newNodeTree = Utils.createNewNodeTree(selectedBuild.childNodes, selectedHtml);
    let parentHtml = parentNode.innerHTML;
    let startIndex = parentHtml.indexOf(selectedHtml);

    return {
      top: parentHtml.slice(0, startIndex),
      middle: newNodeTree.innerHTML,
      bottom: parentHtml.slice(startIndex + selectedHtml.length)
    };
  },

  doesChildrenHaveText(children) {
    let hasText = false;

    children.forEach(child => {
      treeWalk([child], c => {
        if(c.content) {
          hasText = true;
        }
      });
    });

    return hasText;
  }
}