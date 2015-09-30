import React from 'react/addons';
import { Editor } from '../constants/ActionTypes';
import _ from 'lodash';
import { createRandomNumber } from '../../utils/Helpers';
import Utils from '../utils/DOMUtils';
import Helpers from '../../utils/Helpers';
import async from 'async';

import Hashids from 'hashids';
const hashids = new Hashids('hackster', 4);

import { P, A, PRE, BLOCKQUOTE, UL, DIV, FIGURE, FIGCAPTION, IMG, ELEMENT } from '../components/DomElements';
const mapToComponent = {
  'p': React.createFactory(P),
  'a': React.createFactory(A),
  'pre': React.createFactory(PRE),
  'blockquote': React.createFactory(BLOCKQUOTE),
  'ul': React.createFactory(UL),
  'div': React.createFactory(DIV),
  'figure': React.createFactory(FIGURE),
  'figcaption': React.createFactory(FIGCAPTION),
  'code': React.createFactory('code'),
  'strong': React.createFactory('strong'),
  'span': React.createFactory('span'),
  'br': React.createFactory('br'),
  'em': React.createFactory('em'),
  'li': React.createFactory('li'),
  'b': React.createFactory('b')
};

const blockElements = {
  'blockquote': true,
  'pre': true
};

const initialState = {
  html: '',
  dom: [],
  storyJSON: [],
  isFetching: false,
  currentStoreIndex: 0,
  csrfToken: null,
  projectId: null,
  S3BucketURL: null,
  AWSAccessKeyId: null,
  isEditable: true,
  isHovered: false,
  getLatestHTML: false,
  forceUpdate: false,
  cursorPosition: { pos: 0, node: null, offset: null, anchorNode: null, rootHash: null },
  setCursorToNextLine: false,
  showImageToolbar: false,
  imageToolbarData: {},
  isDataLoading: false,
  errorMessenger: { show: false, msg: '' }
};

export default function(state = initialState, action) {
  let dom, newDom, cursorPosition;
  switch (action.type) {

    case Editor.setDOM:
      dom = state.dom;
      newDom = updateComponentAtIndex(dom, action.html, action.index, action.depth);
      return {
        ...state,
        dom: newDom,
        storyJSON: newDom
      };

    case Editor.setInitialDOM:
      newDom = handleInitialDOM(action.json);
      return {
        ...state,
        dom: newDom,
        storyJSON: newDom,
        getLatestHTML: true,
        isFetching: false
      };

    case Editor.setIsFetching:
      return {
        ...state,
        isFetching: action.bool
      };

    case Editor.setCurrentStoreIndex:
      return {
        ...state,
        currentStoreIndex: action.storeIndex
      };

    case Editor.setProjectData:
      return {
        ...state,
        csrfToken: action.csrfToken,
        projectId: action.projectId,
        S3BucketURL: action.S3BucketURL,
        AWSAccessKeyId: action.AWSAccessKeyId
      };

    case Editor.createBlockElement:
      dom = state.dom;
      newDom = handleBlockElementCreation(dom, action.tag, action.position, action.storeIndex);
      return {
        ...state,
        dom: newDom,
        setCursorToNextLine: action.setCursorToNextLine
      };

    case Editor.cleanElement:
      dom = state.dom;
      newDom = cleanElement(dom, action.depth, action.childDepth);
      return {
        ...state,
        dom: newDom
      };

    case Editor.transformBlockElement:
      dom = state.dom;
      newDom = transformBlockElement(dom, action.tag, action.position, action.cleanChildren, action.storeIndex);
      return {
        ...state,
        dom: newDom
      };

    case Editor.transformBlockElements:
      dom = state.dom;
      newDom = transformBlockElements(dom, action.tag, action.elements, action.storeIndex);
      return {
        ...state,
        dom: newDom
      };

    case Editor.prependCE:
      dom = state.dom;
      newDom = prependCE(dom, action.storeIndex);
      return {
        ...state,
        dom: newDom
      };

    case Editor.setFigCaptionText:
      dom = state.dom;
      newDom = setFigCaptionText(dom, action.figureIndex, action.storeIndex, action.html);
      return {
        ...state,
        dom: newDom
      }

    case Editor.removeBlockElements:
      dom = state.dom;
      newDom = removeBlockElements(dom, action.map, action.storeIndex);
      return {
        ...state,
        dom: newDom
      };

    case Editor.wrapOrUnwrapBlockElement:
      dom = state.dom;
      newDom = wrapOrUnwrapBlockElement(dom, action.tag, action.depth, action.shouldWrap);
      return {
        ...state,
        dom: newDom
      };

    case Editor.handleUnorderedList:
      dom = state.dom;
      newDom = handleUnorderedList(dom, action.toList, action.elements, action.parent, action.storeIndex);
      newDom = _mergeLists(dom, action.storeIndex);
      return {
        ...state,
        dom: newDom
      };

    case Editor.removeListItemFromList:
      dom = state.dom;
      newDom = removeListItemFromList(dom, action.parentPos, action.childPos, action.storeIndex);
      return {
        ...state,
        dom: newDom
      };

    case Editor.transformListItemsToBlockElements:
      dom = state.dom;
      newDom = transformListItemsToBlockElements(dom, action.tag, action.depth, action.storeIndex);
      return {
        ...state,
        dom: newDom
      };

    case Editor.isEditable:
      return {
        ...state,
        isEditable: action.bool
      };

    case Editor.getLatestHTML:
      return {
        ...state,
        getLatestHTML: action.bool
      };

    case Editor.forceUpdate:
      return {
        ...state,
        forceUpdate: action.bool
      };

    case Editor.setCursorPosition:
      return {
        ...state,
        cursorPosition: { 
          pos: action.position, 
          node: action.node,
          offset: action.offset,
          anchorNode: action.anchorNode,
          rootHash: action.rootHash
        }
      };

    case Editor.setCursorToNextLine:
      return {
        ...state,
        setCursorToNextLine: action.bool
      };

    case Editor.isHovered:
      return {
        ...state,
        isHovered: action.bool
      };

    case Editor.toggleImageToolbar:
      return {
        ...state,
        showImageToolbar: action.bool,
        imageToolbarData: action.data
      };

    case Editor.updateImageToolbarData:
      return {
        ...state,
        imageToolbarData: action.data
      };

    case Editor.createMediaByType:
      dom = state.dom;
      let { newDom, rootHash } = handleMediaCreation(dom, action.map, action.depth, action.storeIndex, action.mediaType);
      return {
        ...state,
        dom: newDom,
        cursorPosition: {
          ...state.cursorPosition,
          rootHash: rootHash
        },
        isDataLoading: false
      };

    case Editor.addImagesToCarousel:
      dom = state.dom;
      newDom = addImagesToCarousel(dom, action.map, action.storeIndex);
      return {
        ...state,
        dom: newDom,
        isDataLoading: false
      };

    case Editor.deleteImagesFromCarousel:
      dom = state.dom;
      newDom = deleteImagesFromCarousel(dom, action.map, action.depth, action.storeIndex);
      newDom = _mergeAdjacentCE(newDom);
      return {
        ...state,
        dom: newDom
      };

    case Editor.updateShownImage:
      dom = state.dom;
      newDom = updateShownImage(dom, action.activeIndex, action.storeIndex, action.direction);
      return {
        ...state,
        dom: newDom
      };

    case Editor.deleteComponent:
      dom = state.dom;
      newDom = deleteComponent(dom, action.storeIndex);
      newDom = _mergeAdjacentCE(newDom);
      return {
        ...state,
        dom: newDom
      };

    case Editor.createPlaceholderElement:
      dom = state.dom;
      newDom = createPlaceholderElement(dom, action.msg, action.depth, action.storeIndex);
      return {
        ...state,
        dom: newDom,
      };

    case Editor.resetImageUrl:
      dom = state.dom;
      newDom = resetImageUrl(dom, action.imageData, action.storeIndex);
      return {
        ...state,
        dom: newDom
      }

    case Editor.isDataLoading:
      return {
        ...state,
        isDataLoading: action.bool
      };

    case Editor.splitBlockElement:
      dom = state.dom;
      newDom = handleSplitBlockElement(dom, action.tagType, action.nodes, action.depth, action.storeIndex);
      return {
        ...state,
        dom: newDom
      };

    case Editor.toggleErrorMessenger:
      let errorMessenger = { show: action.show, msg: action.msg }
      return {
        ...state,
        errorMessenger: errorMessenger
      };

    default:
      return state;
  };
}

function handleInitialDOM(json) {
  json = json || [];

  if(json.length < 1) {
    let CE = {
      type: 'CE',
      hash: hashids.encode(Math.floor(Math.random() * 9999 + 1)),
      json: [{
        tag: 'p',
        content: 'Tell your story...',
        attribs: {
          class: "react-editor-placeholder-text"
        },
        children: []
      }]
    };
    CE.json = createArrayOfComponents(CE.json);
    json.push(CE);
  } else {
    json = json.map(item => {
      if(item.type === 'CE') {
        item.json = createArrayOfComponents(item.json);
        return item;
      } else {
        return item;
      }
    });
  }

  return json;
}

function handleBlockElementCreation(dom, tag, position, storeIndex) {
  let component = dom[storeIndex];
  let json = component.json;
  let reactEl = mapToComponent[tag];
  let tagProps = { hash: hashids.encode(Math.floor(Math.random() * 9999 + 1)) };
  let el = reactEl({key: createRandomNumber(), tagProps, children: ['']});


  if(json.length < 1) {
    json.push(el);
  } else {
    json.splice(position+1, 0, el);
  }

  component.json = json;
  dom.splice(storeIndex, 1, component);

  return dom;
}

function _deepSearchForNodeByHash(rootEl, offset, hash) {
  let target, stack = [];

  (function recurse(el) {
    let child;


    if(el.props.children.length < 1) {
      return;
    }

    stack.push(el.props.children);

    for(let i = 0; i < el.props.children.length; i++) {
      child = el.props.children[i];

      if(child.props.tagProps.hash === hash) {
        target = { position: i, child: child };
        break;
      }

      if(Array.isArray(child.props.children) && child.props.children.length) {
        recurse(child);
      }
    }

  }(rootEl));

  return target;
}

function transformBlockElement(dom, tag, position, cleanChildren, storeIndex) {
  let component = dom[storeIndex];
  let elToReplace = component.json[position];

  if(elToReplace !== undefined) {
    let displayName = elToReplace.type.displayName ? elToReplace.type.displayName : elToReplace.type;

    if(tag === displayName.toLowerCase()) { // Revert tag to Paragraph.
      tag = 'p';
    }
    let reactEl = mapToComponent[tag];
    let tagProps = { hash: elToReplace.props.tagProps.hash } || { hash: hashids.encode(Math.floor(Math.random() * 9999 + 1)) };
    let children = cleanChildren === true ? [''] : elToReplace.props.children;
    let el = reactEl({key: createRandomNumber(), tagProps, children: children });

    component.json.splice(position, 1, el);
    // If the Element is a PRE and its the last El in the DOM, append a Paragraph below it.
    if(el.type.displayName !== undefined && el.type.displayName.toLowerCase() === 'pre' && position === dom.length-1) {
      component.json = appendParagraph(component.json);
    }

    dom.splice(storeIndex, 1, component);
    return dom;
  } else {
    return;
  }
}

function transformBlockElements(dom, tag, elements, storeIndex) {
  let newDom;
  elements.forEach((element) => {
    /** Prevents any DIV block to be transformed. */
    if(element.nodeName !== 'DIV' && element.nodeName !== 'UL') {
      newDom = transformBlockElement(newDom || dom, tag, element.depth, false, storeIndex);
    } else if(element.nodeName === 'UL') {
      newDom = transformListItemsToBlockElements(newDom || dom, tag, element.depth, storeIndex);
    }
  });
  return newDom;
}

function removeBlockElements(dom, map, storeIndex) {
  let component = dom[storeIndex];
  let json = component.json;
  let indexes = _.map(map, function(item) {
    return item.depth;
  });

  _.pullAt(json, indexes); // Mutates json, removes indexes.
  
  if(json[0] === undefined || json.length < 1) {
    json = [];
    let P = mapToComponent['p'];
    let tagProps = { hash: hashids.encode(Math.floor(Math.random() * 9999 + 1)) };
    json.push( P({key: createRandomNumber(), tagProps, children: ['']}) );
  }

  component.json = json;
  dom.splice(storeIndex, 1, component);
  return dom;
}

function removeListItemFromList(dom, parentPos, childPos, storeIndex) {
  let component = dom[storeIndex];
  let json = component.json;
  let parentEl = json[parentPos];
  
  parentEl.props.children = parentEl.props.children.filter(function(child, index) {
    if(index === childPos) {
      return false;
    } else {
      return true;
    }
  });

  json.splice(parentPos, 1, parentEl);
  component.json = json;
  dom.splice(storeIndex, 1, component);
  return dom;
}

function transformListItemsToBlockElements(dom, tag, position, storeIndex) {
  let component = dom[storeIndex];
  let json = component.json;
  let elToReplace = json[position];
  let children = elToReplace.props.children;
  let reactEl = mapToComponent[tag], el, tagProps, newChildren;

  // If the UL is wrapped in another block el, this digs into the UL since all we care about is the lis to trasform. 
  if(!Array.isArray(children) && children.type.displayName === 'UL') {
    children = children.props.children;
  }

  _.forEach(children, function(child, index) {
    if(child !== null && child.type.displayName !== 'DIV') {
      tagProps = index === 0 ? {hash: elToReplace.props.tagProps.hash} : {hash: hashids.encode(Math.floor(Math.random() * 9999 + 1))};
      newChildren = child.props.children;
      el = reactEl({ tagProps, children: newChildren });

      if(index === 0) {
        json.splice(position+index, 1, el);
      } else {
        json.splice(position+index, 0, el);
      } 

      // If the Element is a PRE and its the last El in the DOM, append a Paragraph below it.
      if(el.type.displayName !== undefined && el.type.displayName.toLowerCase() === 'pre' && position === dom.length-1) {
        json = appendParagraph(json);
      }
    }
  });

  component.json = json;
  dom.splice(storeIndex, 1, component);
  return dom;
}

function prependCE(dom, storeIndex) {
  let P = mapToComponent['p'];
  let p = P({ tagProps: { hash: hashids.encode(Math.floor(Math.random() * 9999 + 1)) }, 
              style: {}, 
              className: '', 
              key: createRandomNumber(), 
              children: [''] 
            });
  let CE = {
    type: 'CE',
    json: [],
    hash: hashids.encode(Math.floor(Math.random() * 9999 + 1))
  };
  CE.json.push(p);
  /** We either add a CE or append a Paragraph to the previous CE. */
  if(storeIndex === 0 || dom[storeIndex-1].type !== 'CE') {
    dom.splice(storeIndex, 0, CE);
  } else {
    let component = dom[storeIndex-1];
    component.json.push(p);
    dom.splice(storeIndex-1, 1, component);
  }

  return dom;
}

function setFigCaptionText(dom, figureIndex, storeIndex, html) {
  let component = dom[storeIndex];
  let images = component.images;
  images[figureIndex].figcaption = html;

  component.images = images;
  dom.splice(storeIndex, 1, component);
  return dom;
}

function _getNodePositionByHash(dom, hash) {
  let nodePosition;

  for(var i = 0; i < dom.length; i++) {
    let node = dom[i];
    if(node.props.tagProps.hash === hash) {
      nodePosition = i;
      break;
    }
  }

  return nodePosition;
}

function handleUnorderedList(dom, toList, elements, parentNode, storeIndex) {
  let children, newChildren, reactEl, tagProps;
  let component = dom[storeIndex];
  let json = component.json;

  if(toList) {
    let li = mapToComponent['li'], 
        ul, el, depth;

    if(parentNode.previousLength !== null) {
      depth = elements[0].depth - (parentNode.previousLength - 1);
    } else {
      depth = elements[0].depth;
    }

    children = _.map(elements, function(element) {
      if(parentNode.previousLength !== null) {
        el = json[element.depth - (parentNode.previousLength - 1)];
      } else {
        el = json[element.depth];
      }
      newChildren = el.props.children;
      return li({ key: createRandomNumber(), children: newChildren });
    });

    reactEl = mapToComponent['ul'];
    tagProps = json[depth].props.tagProps || { hash: hashids.encode(Math.floor(Math.random() * 9999 + 1)) };
    ul = reactEl({ key: createRandomNumber(), tagProps, children: children });

    json.splice(depth, elements.length, ul);
  } else {
    let depth = _getNodePositionByHash(json, parentNode.hash);
    let ul = depth !== undefined ? json[depth] : json[parentNode.depth];
    json = _transformListItems(json, elements, ul, depth || parentNode.depth);
  }

  component.json = json;
  dom.splice(storeIndex, 1, component);
  return dom;
}

function _transformListItems(dom, elements, parentNode, parentPosition) {
  let parentHashToPassOn = parentNode.props.tagProps,
      children = parentNode.props.children,
      reactUL = mapToComponent['ul'],
      newDom = dom,
      childrenToTransform, UL, tagProps ;

  if(children.length > elements.length) {

    if(elements[0] === 0) { // Selected the first li and maybe more.
      childrenToTransform = _.pullAt(children, elements);  // _.pullAt mutates children.

      newDom.splice(parentPosition, 1); // Removes old UL.
      newDom = _transformChildren(newDom, childrenToTransform, parentPosition, parentHashToPassOn);

      parentNode.props.children = children;
      parentNode.props.tagProps = { hash: hashids.encode(Math.floor(Math.random() * 9999 + 1)) };
      newDom.splice((parentPosition + elements[elements.length-1] + 1), 0, parentNode);
    } else if(elements[0] !== 0) { // Selected one or more in the middle.
      let firstChildren = _.take(children, elements[0]);
      let restOfChildren = _.slice(children, (elements[elements.length-1]+1));
      childrenToTransform = _.pullAt(children, elements);

      // Start
      parentNode.props.children = firstChildren;
      newDom.splice(parentPosition, 1, parentNode);

      // Middle
      newDom = _transformChildren(newDom, childrenToTransform, (parentPosition + 1));

      // End
      if(restOfChildren.length > 0) {
        UL = reactUL({tagProps: { hash: hashids.encode(Math.floor(Math.random() * 9999 + 1)) }, children: restOfChildren});
        newDom.splice((parentPosition + elements[elements.length-1] + 1), 0, UL);
      }
    }

  } else if(children.length === elements.length) { // Every li is selected.
    newDom.splice(parentPosition, 1);
    newDom = _transformChildren(newDom, children, parentPosition, parentHashToPassOn);
  }

  return newDom;
}

function _transformChildren(dom, children, position, parentHash) {
  let newDom = dom;
  let reactP = mapToComponent['p'];
  let P, tagProps, newChildren;

  _.forEach(children, function(child, index) {
    tagProps = (index === 0 && parentHash !== undefined) ? parentHash : { hash: hashids.encode(Math.floor(Math.random() * 9999 + 1)) };
    newChildren = child.props.children;
    P = reactP({tagProps, children: newChildren});
    newDom.splice((parseInt(position) + index), 0, P);
  });

  return newDom;
}
/** 
 * Runs after everyafter every handleUnorderedList. 
 * It checks if theres ULs above and below the list currently being created.
 */
function _mergeLists(dom, storeIndex) {
  let component = dom[storeIndex],
      json = component.json, 
      children = [],
      reactEl = mapToComponent['ul'],
      positionsToMerge = _createPositionsToMerge(json, 'UL'),
      UL;

  _.forEach(positionsToMerge, function(position) {
    let parentNodePos = position.shift();
    let parentNode = json[parentNodePos];
    children = [];

    _.forEach(position, function(ulPos) {
      children = children.concat(json[ulPos].props.children);
    });

    UL = reactEl({tagProps: parentNode.props.tagProps, children: parentNode.props.children.concat(children)});
    json.splice(parentNodePos, position.length+1, UL);
  });

  component.json = json;
  dom.splice(storeIndex, 1, component);
  return dom;
}

function _createPositionsToMerge(newDom, el) {
  let positions = [],
      positionsToMerge = [],
      isEl;

  _.forEach(newDom, function(child, index) {
    isEl = child.type.displayName && child.type.displayName === el;
    if(isEl) {
      positions.push(index);
    } else {
      positions = [];
    }

    if(positions.length > 1 && (newDom[index+1] === undefined || newDom[index+1].type.displayName !== el)) {
      positionsToMerge.push(positions);
    }
  });

  return positionsToMerge;
}

function handleMediaCreation(dom, map, depth, storeIndex, mediaType) {
  let component = dom[storeIndex];
  let json = component.json;
  let media = {
    type: mediaType,
    images: map,
    hash: hashids.encode(Math.floor(Math.random() * 9999 + 1))
  };
  let rootHash;

  /** Sets the first image to show. */
  media.images[0].show = true;

  /** If we're adding a Carousel to the end of a CE.
    * Else we need to splice the content of the CE by depth.
   */
  if(depth === json.length-1) {
    let removedNode = json.pop();
    let itemsToRemove = 0;
    storeIndex += 1;

    /** If theres nothing left in the element, remove it. */
    if(json.length < 1) {
      storeIndex -= 1;
      itemsToRemove = 1;
    }

    let P = mapToComponent['p'];
    rootHash = hashids.encode(Math.floor(Math.random() * 9999 + 1));
    let CE = {
      type: 'CE',
      json: [],
      hash: rootHash
    };

    let p = P({ tagProps: { hash: removedNode.props.tagProps.hash || hashids.encode(Math.floor(Math.random() * 9999 + 1)) }, 
                style: {}, 
                className: '', 
                key: createRandomNumber(), 
                children: mediaType === 'Carousel' ? [removedNode.props.children] : ['']
              });

    CE.json.push(p);
    dom.splice(storeIndex, itemsToRemove, media);
    dom.push(CE);
  } else if(depth === 0 && json[depth+1].props.children) {
    dom.splice(storeIndex, 0, media);
  } else {
    rootHash = hashids.encode(Math.floor(Math.random() * 9999 + 1));
    let bottomDepthStart = mediaType === 'Video' ? depth+1 : depth;
    let top = json.slice(0, depth);
    let bottom = json.slice(bottomDepthStart, json.length);
    let topCE = { type: 'CE', hash: component.hash, json: top };
    let bottomCE = { type: 'CE', hash: rootHash, json: bottom };

    dom.splice(storeIndex, 1, topCE);
    dom.splice(storeIndex+1, 0, media);
    dom.splice(storeIndex+2, 0, bottomCE);
  }

  return { newDom: dom, rootHash: rootHash };
}

function addImagesToCarousel(dom, map, storeIndex) {
  let component = dom[storeIndex];
  let newImages = map.map(image => {
    return { url: image.url, alt: image.alt, width: image.width, figcaption: null };
  });

  /** Remove current shown image and show the last image added. */
  component.images.forEach(image => {
    if(image.show) {
      image.show = false;
    }
  });
  newImages[newImages.length-1].show = true;

  component.images.push(...newImages);
  dom.splice(storeIndex, 1, component);
  return dom;
}

function updateShownImage(dom, activeIndex, storeIndex, direction) {
  let component = dom[storeIndex];
  let images = component.images;

  images[activeIndex].show = false;

  if(direction === 'left') {
    if(activeIndex === 0) {
      images[images.length-1].show = true;
    } else {
      images[activeIndex-1].show = true;
    }
  } else {
    if(activeIndex === images.length-1) {
      images[0].show = true;
    } else {
      images[activeIndex+1].show = true;
    }
  }

  component.images = images;
  dom.splice(storeIndex, 1, component);
  return dom;
}

function deleteImagesFromCarousel(dom, map, position, storeIndex) {
  let component = dom[storeIndex];
  let images = component.images;
  let replaceShownImage = false;
  let newImages, indexOfShown;

  if(map.length < 1) {
    /** If we're deleting one image, its the one shown. 
      * Else we look for it.
    */
    newImages = _.filter(images, (image, index) => {
      if(image.show) {
        replaceShownImage = true;
        indexOfShown = index;
        return false;
      } else {
        return true;
      }
    });
  } else {
    newImages = _.filter(images, (image, index) => {
      if(_.includes(map, image)) {
        if(image.show) {
          replaceShownImage = true;
          indexOfShown = index;
        }
        return false;
      } else {
        return true;
      }
    });
  }

  /** If user is deleting all the images, delete the carousel while we're at it and be done with it. */
  if(newImages.length < 1) {
    let P = mapToComponent['p'];
    let CE = {
      type: 'CE',
      json: [],
      hash: component.hash
    };
    let p = P({ tagProps: { hash: hashids.encode(Math.floor(Math.random() * 9999 + 1)) }, 
                style: {}, 
                className: '', 
                key: createRandomNumber(), 
                children: [''] 
              });
    CE.json.push(p);
    dom.splice(storeIndex, 1, CE);
    return dom;
  }

  if(replaceShownImage) {
    indexOfShown = (indexOfShown - 1) < 0 ? 0 : (indexOfShown-1);
    newImages[indexOfShown].show = true;
  }

  component.images = newImages;
  dom.splice(storeIndex, 1, component);
  return dom;
}

function _mergeAdjacentCE(dom) {
  let newDom = [];

  dom.forEach((component, index) => {
    if(index > 0 && dom[index-1].type === 'CE' && component.type === 'CE') {
      newDom[newDom.length-1].json.push(...component.json);
    } else {
      newDom.push(component);
    }
  });

  return newDom;
}

function deleteComponent(dom, storeIndex) {
  dom.splice(storeIndex, 1);
  return dom;
}

function resetImageUrl(dom, data, storeIndex) {
  let component = dom[storeIndex];
  let images = component.images.map(image => {
    if(image.uuid = data.uuid) {
      image = Object.assign({}, image, data);
      return image;
    } else {
      return image;
    }
  });
  dom.splice(storeIndex, 1, component);
  return dom;
}

function handleSplitBlockElement(dom, tagType, nodes, depth, storeIndex) {
  let component = dom[storeIndex];
  let json = component.json;

  let node = React.cloneElement(json[depth], {}, createArrayOfComponents(nodes.shift()));
  json.splice(depth, 1, node);

  let Blockquote = mapToComponent['blockquote'];
  let BLOCKQUOTE = Blockquote({
    tagProps: { hash: hashids.encode(Math.floor(Math.random() * 9999 + 1)) },
    key: createRandomNumber(),
    children: createArrayOfComponents(nodes.shift())
  });

  json.splice(depth+1, 0, BLOCKQUOTE);

  if(nodes[0].length) {
    let p = mapToComponent['p'];
    let P = p({
      tagProps: { hash: hashids.encode(Math.floor(Math.random() * 9999 + 1)) },
      key: createRandomNumber(),
      children: createArrayOfComponents(nodes.shift())
    });

    json.splice(depth+2, 0, P);
  }

  component.json = json;
  dom.splice(storeIndex, 1, component);
  return dom;
}

function appendParagraph(dom) {
  let P = mapToComponent['p'];
  let tagProps = { hash: hashids.encode(Math.floor(Math.random() * 9999 + 1)) };
  dom.push( P({ key: createRandomNumber(), tagProps, children: [''] }) );

  return dom;
}

function createPlaceholderElement(dom, msg, position, storeIndex) {
  let component = dom[storeIndex];
  let json = component.json;
  let replaceLine = 1;

  let P = mapToComponent['p'];
  let tagProps = { hash: hashids.encode(Math.floor(Math.random() * 9999 + 1)) };
  let el = P({ key: createRandomNumber(), tagProps, className: 'react-editor-placeholder-text', children: [msg] });

  if(json[position].props.children && json[position].props.children.length > 0) {
    replaceLine = 0;
  }

  json.splice(position, replaceLine, el);
  component.json = json;
  dom.splice(storeIndex, 1, component);
  return dom;
}

function createStyleObjectFromString(string) {
  let item,
      styleProp,
      styleObj = {},
      styles = string.split(';');

  _.forEach(styles, function(s, index) {
    if(s !== '' && s !== undefined && s.split(':').indexOf('url(data') === 1) {  // Checks for base64 dataURIs.
      let uri;
      item = s.split(':');
      uri =  item[1] + ':' + item[2] + ';' + styles[index+1];
      styles[index+1] = '';
      styleObj[item[0]] = uri;
    } else if(s !== '' || s !== undefined) {
      item = s.split(':');
      styleProp = item[0].split('-').length > 0 ? camelCaseStyleProp(item[0]) : item[0];
      styleObj[styleProp] = item[1];
    }
  });

  return styleObj;
}

function camelCaseStyleProp(prop) {
  let arr = prop.split('-');

  arr = arr.map((item, index) => {
    if(index !== 0) {
      return item.substring(0, 1).toUpperCase() + item.substring(1, item.length);
    } else {
      return item;
    }
  });

  return arr.join('');
}

function updateComponentAtIndex(dom, json, index, depth) {
  let component = dom[index];
  // let row = component.json[depth];

  // row.props.children = createArrayOfComponents(json);
  // component.json[depth] = row;

  component.json = createArrayOfComponents(json);

  dom.splice(index, 1, component);
  return dom;
}

function createArrayOfComponents(dom) {
  return (function recurse(source, lastHash) {
    lastHash = lastHash || null;
    return source.map(function(item, index) {

      let tagProps = { tag: item.tag }, style = {}, hash, props, el;
      let tagPropsMap = {
        'a': Object.assign({}, { href: item.attribs.href }),
        'iframe': Object.assign({}, { src: item.attribs.src }),
        'img': Object.assign({}, { dataSrc: item.attribs['data-src'], src: item.attribs.src, alt: item.attribs.alt }),
        'div': Object.assign({}, { bgImage: item.attribs['data-bg-image'] || null, 
                                   contentEditable: item.attribs.contenteditable || null,
                                   'data-type': item.attribs['data-type'] || null,
                                   'data-video-id': item.attribs['data-video-id'] || null }),
        'figure': Object.assign({}, { type: item.attribs['data-type'] || null })
      };

      /** Creates React Factory component.  Forces unknown elements to Paragraphs */
      el = mapToComponent[item.tag];
      if(el === undefined) {
        el = mapToComponent['p'];
      }

      /** Creates style object from string */
      if(item.attribs.style && item.tag !== 'span') {
        style = Object.assign({}, createStyleObjectFromString(item.attribs.style));
      }
      if(tagPropsMap.hasOwnProperty(item.tag)) {
        tagProps = tagPropsMap[item.tag];
      }

      /** Adds a hash attribute for quicker lookup and replaces duplicates from content editable. */
      if(item.attribs === undefined || item.attribs['data-hash'] === undefined) {
        tagProps = Object.assign(tagProps, { hash: hashids.encode(index + Math.floor(Math.random() * 9999 + 1)) });
      } else if(item.attribs['data-hash'] !== undefined) {
        hash = item.attribs['data-hash'];

        if(lastHash === hash) {
          hash = hashids.encode(index + Math.floor(Math.random() * 9999 + 1));
        }

        tagProps = Object.assign({}, tagProps, { hash: hash });
        lastHash = hash;
      }

      if(!item.children || !item.children.length) {
        props = Object.assign({}, { key: createRandomNumber() }, { className: item.attribs.class }, { style: style }, { tagProps: tagProps }, { children: item.content });
        return el(props);
      } else {
        let children = recurse(item.children, lastHash); 
        props = Object.assign({}, { key: createRandomNumber() }, { className: item.attribs.class }, { style: style }, { tagProps: tagProps }, { children: children });
        return el(props);
      }
    }).filter(item => { return item !== null || item !== undefined; });
  }(dom));
}

