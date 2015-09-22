import { Editor } from '../constants/ActionTypes';
import Request from '../utils/Requests';

export function setDOM(html, index, depth) {
  return {
    type: Editor.setDOM,
    index: index,
    html: html,
    depth: depth
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

export function setCurrentStoreIndex(storeIndex) {
  return {
    type: Editor.setCurrentStoreIndex,
    storeIndex: storeIndex
  };
}

export function setProjectData(projectId, csrfToken) {
  return {
    type: Editor.setProjectData,
    projectId: projectId,
    csrfToken: csrfToken
  };
}

export function createBlockElement(tag, position, setCursorToNextLine, storeIndex) {
  return {
    type: Editor.createBlockElement,
    tag: tag,
    position: position,
    setCursorToNextLine: setCursorToNextLine,
    storeIndex: storeIndex
  };
}

export function transformBlockElement(tag, position, cleanChildren, storeIndex) {
  return {
    type: Editor.transformBlockElement,
    tag: tag,
    position: position,
    cleanChildren: cleanChildren,
    storeIndex: storeIndex
  };
}

export function transformBlockElements(tag, elements, storeIndex) {
  return {
    type: Editor.transformBlockElements,
    tag: tag,
    elements: elements,
    storeIndex: storeIndex
  };
}

export function cleanElement(depth, childDepth) {
  return {
    type: Editor.cleanElement,
    depth: depth,
    childDepth: childDepth
  };
}

export function removeBlockElements(map, storeIndex) {
  return {
    type: Editor.removeBlockElements,
    map: map,
    storeIndex: storeIndex
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

export function removeListItemFromList(parentPos, childPos, storeIndex) {
  return {
    type: Editor.removeListItemFromList,
    parentPos: parentPos,
    childPos: childPos,
    storeIndex: storeIndex
  };
}

export function transformListItemsToBlockElements(tag, depth) {
  return {
    type: Editor.transformListItemsToBlockElements,
    tag: tag,
    depth: depth
  };
}

export function prependCE(storeIndex) {
  return {
    type: Editor.prependCE,
    storeIndex: storeIndex
  };
}

export function setFigCaptionText(figureIndex, storeIndex, html) {
  return {
    type: Editor.setFigCaptionText,
    figureIndex: figureIndex,
    storeIndex: storeIndex,
    html: html
  };
}

export function handleUnorderedList(toList, elements, parent, storeIndex) {
  return {
    type: Editor.handleUnorderedList,
    toList: toList,
    elements: elements,
    parent: parent,
    storeIndex: storeIndex
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

export function setCursorPosition(position, node, offset, anchorNode, rootHash) {
  // console.log('Cursor ACTION: ', position, node, offset, anchorNode);
  return {
    type: Editor.setCursorPosition,
    position: position,
    node: node,
    offset: offset,
    anchorNode: anchorNode,
    rootHash: rootHash
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

export function createMediaByType(map, depth, storeIndex, mediaType) {
  return {
    type: Editor.createMediaByType,
    map: map,
    depth: depth,
    storeIndex: storeIndex,
    mediaType: mediaType
  };
}

export function addImagesToCarousel(map, storeIndex) {
  return {
    type: Editor.addImagesToCarousel,
    map: map,
    storeIndex: storeIndex
  };
}

export function deleteImagesFromCarousel(map, depth, storeIndex) {
  return {
    type: Editor.deleteImagesFromCarousel,
    map: map,
    depth: depth,
    storeIndex: storeIndex
  };
}

export function updateShownImage(activeIndex, storeIndex, direction) {
  return {
    type: Editor.updateShownImage,
    activeIndex: activeIndex,
    storeIndex: storeIndex,
    direction: direction
  };
}

export function deleteComponent(storeIndex) {
  return {
    type: Editor.deleteComponent,
    storeIndex: storeIndex
  };
}

export function createPlaceholderElement(msg, depth, storeIndex) {
  return {
    type: Editor.createPlaceholderElement,
    msg: msg,
    depth: depth,
    storeIndex: storeIndex
  };
}