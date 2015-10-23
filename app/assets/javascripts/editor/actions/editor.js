import { Editor } from '../constants/ActionTypes';
import Request from '../utils/Requests';
import ImageHelpers from '../../utils/Images'; 

export function setDOM(html, depth, storeIndex) {
  return {
    type: Editor.setDOM,
    html: html,
    depth: depth,
    storeIndex: storeIndex
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
        dispatch(toggleErrorMessenger(true, 'We had an issue getting your story!'));
      });
  }
}

export function setIsFetching(bool) {
  return {
    type: Editor.setIsFetching,
    bool: bool
  };
}

export function setCurrentStoreIndex(storeIndex) {
  return {
    type: Editor.setCurrentStoreIndex,
    storeIndex: storeIndex
  };
}

export function setProjectData(projectId, csrfToken, S3BucketURL, AWSAccessKeyId) {
  return {
    type: Editor.setProjectData,
    projectId: projectId,
    csrfToken: csrfToken,
    S3BucketURL: S3BucketURL,
    AWSAccessKeyId: AWSAccessKeyId
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

export function createBlockElementWithChildren(children, tag, position, setCursorToNextLine, storeIndex) {
  return {
    type: Editor.createBlockElementWithChildren,
    children: children,
    tag: tag,
    position: position,
    setCursorToNextLine: setCursorToNextLine,
    storeIndex: storeIndex
  }
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

export function transformListItemsToBlockElements(tag, depth, storeIndex) {
  return {
    type: Editor.transformListItemsToBlockElements,
    tag: tag,
    depth: depth,
    storeIndex: storeIndex
  };
}

export function prependCE(storeIndex) {
  return {
    type: Editor.prependCE,
    storeIndex: storeIndex
  };
}

export function insertCE(storeIndex) {
  return {
    type: Editor.insertCE,
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

export function resetImageUrl(imageData, storeIndex, mediaHash) {
  return {
    type: Editor.resetImageUrl,
    imageData: imageData,
    mediaHash: mediaHash,
    storeIndex: storeIndex
  };
}

export function removeImageFromList(imageData, storeIndex, mediaHash) {
  return {
    type: Editor.removeImageFromList,
    imageData: imageData,
    storeIndex: storeIndex,
    mediaHash: mediaHash
  }
}

export function uploadImagesToServer(files, storeIndex, mediaHash, S3BucketURL, AWSAccessKeyId, csrfToken, projectId) {
  console.log('ACTION', S3BucketURL, AWSAccessKeyId);
  return function(dispatch) {
    files.forEach(file => {
      return ImageHelpers.getS3AuthData(file.name)
        .then(data => {
          return ImageHelpers.postToS3(data, file, S3BucketURL, AWSAccessKeyId);
        })
        .then(url => {
          return ImageHelpers.postURLToServer(url, projectId, csrfToken, 'image', 'tmp-file-0');
        })
        .then(response => {
          let body = Object.assign({}, response.body, file);
          dispatch(resetImageUrl(body, storeIndex, mediaHash));
        })
        .catch(err => {
          if(err) {
            console.log('ERR', err);
            dispatch(removeImageFromList(file, storeIndex, mediaHash));
            dispatch(toggleErrorMessenger(true, 'Problem uploading image:' + file.name));
          }
        });
    });

  }
}

export function isDataLoading(bool) {
  return {
    type: Editor.isDataLoading,
    bool: bool
  };
}

export function splitBlockElement(tagType, nodes, depth, storeIndex) {
  return {
    type: Editor.splitBlockElement,
    nodes: nodes,
    depth: depth,
    storeIndex: storeIndex
  };
}

export function toggleErrorMessenger(show, msg) {
  return {
    type: Editor.toggleErrorMessenger,
    show: show,
    msg: msg
  };
}

export function handlePastedHTML(html, depth, storeIndex) {
  return {
    type: Editor.handlePastedHTML,
    html: html,
    depth: depth,
    storeIndex: storeIndex
  };
}

export function toggleIE(bool) {
  return {
    type: Editor.toggleIE,
    bool: bool
  };
}