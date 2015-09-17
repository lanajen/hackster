import { Editor } from '../constants/ActionTypes';
import Request from '../utils/Requests';

export function setDOM(dom) {
  return {
    type: Editor.setDOM,
    dom: dom
  };
}

export function setInitialDOM(json) {
  return {
    type: Editor.setInitialDOM,
    json: json
  };
}

export function fetchInitialDOM(projectId, csrfToken) {

  return function (dispatch) {
    return Request.getStory(projectId, csrfToken)
      .then(result => {
        dispatch(setInitialDOM(result));
      }).catch(err => { 
        console.log(err);
      // handle err 
      });
  }
}

export function setProjectData(projectId, csrfToken) {
  return {
    type: Editor.setProjectData,
    projectId: projectId,
    csrfToken: csrfToken
  };
}

export function createBlockElement(tag, position, setCursorToNextLine) {
  return {
    type: Editor.createBlockElement,
    tag: tag,
    position: position,
    setCursorToNextLine: setCursorToNextLine
  };
}

export function createBlockElementWithChildren(tag, position, offset, hash) {
  return {
    type: Editor.createBlockElementWithChildren,
    tag: tag,
    position: position,
    offset: offset,
    hash: hash
  };
}

export function transformBlockElement(tag, position, cleanChildren) {
  return {
    type: Editor.transformBlockElement,
    tag: tag,
    position: position,
    cleanChildren: cleanChildren
  };
}

export function transformBlockElements(tag, elements) {
  return {
    type: Editor.transformBlockElements,
    tag: tag,
    elements: elements
  };
}

export function cleanElement(depth, childDepth) {
  return {
    type: Editor.cleanElement,
    depth: depth,
    childDepth: childDepth
  };
}

export function removeBlockElements(map) {
  return {
    type: Editor.removeBlockElements,
    map: map
  };
}

export function wrapOrUnwrapBlockElement(tag, depth, shouldWrap) {
  return {
    type: Editor.wrapOrUnwrapBlockElement,
    tag: tag,
    depth: depth,
    shouldWrap: shouldWrap
  };
}

export function removeListItemFromList(parentPos, childPos) {
  return {
    type: Editor.removeListItemFromList,
    parentPos: parentPos,
    childPos: childPos
  };
}

export function transformListItemsToBlockElements(tag, depth) {
  return {
    type: Editor.transformListItemsToBlockElements,
    tag: tag,
    depth: depth
  };
}

export function handleUnorderedList(toList, elements, parent) {
  return {
    type: Editor.handleUnorderedList,
    toList: toList,
    elements: elements,
    parent: parent
  };
}


export function isEditable(bool) {
  return {
    type: Editor.isEditable,
    bool: bool
  }
}

export function getLatestHTML(bool) {
  return {
    type: Editor.getLatestHTML,
    bool: bool
  };
}

export function forceUpdate(bool) {
  return {
    type: Editor.forceUpdate,
    bool: bool
  };
}

export function setCursorPosition(position, node, offset, anchorNode) {
  // console.log('Cursor ACTION: ', position, node, offset, anchorNode);
  return {
    type: Editor.setCursorPosition,
    position: position,
    node: node,
    offset: offset,
    anchorNode: anchorNode
  };
}

export function setCursorToNextLine(bool) {
  return {
    type: Editor.setCursorToNextLine,
    bool: bool
  };
}

export function isHovered(bool) {
  return {
    type: Editor.isHovered,
    bool: bool
  }
}

export function toggleImageToolbar(bool, data) {
  return {
    type: Editor.toggleImageToolbar,
    bool: bool,
    data: data
  };
}

export function updateImageToolbarData(data) {
  return {
    type: Editor.updateImageToolbarData,
    data: data
  };
}

export function createCarousel(map, depth) {
  return {
    type: Editor.createCarousel,
    map: map,
    depth: depth
  };
}

export function addImagesToCarousel(map, depth) {
  return {
    type: Editor.addImagesToCarousel,
    map: map,
    depth: depth
  };
}

export function deleteImagesFromCarousel(map, depth) {
  return {
    type: Editor.deleteImagesFromCarousel,
    map: map,
    depth: depth
  };
}

export function handleVideo(data, depth) {
  return {
    type: Editor.handleVideo,
    data: data,
    depth: depth
  };
}

export function createPlaceholderElement(msg, depth) {
  return {
    type: Editor.createPlaceholderElement,
    msg: msg,
    depth: depth
  };
}