import React from 'react/addons';
import { Editor } from '../constants/ActionTypes';
import _ from 'lodash';
import { createRandomNumber } from '../../utils/Helpers';
import Utils from '../utils/DOMUtils';
import Helpers from '../../utils/Helpers';
import async from 'async';

import Hashids from 'hashids';
const hashids = new Hashids('hackster', 4);

import { P, A, PRE, BLOCKQUOTE, UL, DIV, FIGURE, FIGCAPTION, IMG, IFRAME, CAROUSEL, VIDEO, ELEMENT } from '../components/DomElements';
const mapToComponent = {
  'p': React.createFactory(P),
  'a': React.createFactory(A),
  'pre': React.createFactory(PRE),
  'blockquote': React.createFactory(BLOCKQUOTE),
  'ul': React.createFactory(UL),
  'div': React.createFactory(DIV),
  'figure': React.createFactory(FIGURE),
  'figcaption': React.createFactory(FIGCAPTION),
  'img': React.createFactory(IMG),
  'iframe': React.createFactory(IFRAME),
  'carousel': React.createFactory(CAROUSEL),
  'video': React.createFactory(VIDEO),
  'strong': React.createFactory('strong'),
  'span': React.createFactory('span'),
  'br': React.createFactory('br'),
  'em': React.createFactory('em'),
  'li': React.createFactory('li'),
  'code': React.createFactory('code'),
  'button': React.createFactory('button'),
  'b': React.createFactory('b'),
  'i': React.createFactory('i')
};

const blockElements = {
  'blockquote': true,
  'pre': true
};

const initialState = {
  html: '',
  dom: [],
  csrfToken: null,
  projectId: null,
  isEditable: true,
  isHovered: false,
  getLatestHTML: false,
  forceUpdate: false,
  cursorPosition: { pos: 0, node: null, offset: null, anchorNode: null },
  setCursorToNextLine: false,
  showImageToolbar: false,
  imageToolbarData: {}
};

export default function(state = initialState, action) {
  let dom, newDom, cursorPosition;
  switch (action.type) {
    case Editor.setDOM:
      let ReactifiedDOM = createArrayOfComponents(action.dom);
      return {
        ...state,
        dom: ReactifiedDOM
      };

    case Editor.setInitialDOM:
      console.log('THIS!', action.json);
      let initDom = handleInitialDOM(action.json);
      newDom = createArrayOfComponents(initDom);
      return {
        ...state,
        dom: newDom
      };

    case Editor.setProjectData:
      return {
        ...state,
        csrfToken: action.csrfToken,
        projectId: action.projectId
      };

    case Editor.createBlockElement:
      dom = state.dom;
      newDom = handleBlockElementCreation(dom, action.tag, action.position);
      return {
        ...state,
        dom: newDom,
        setCursorToNextLine: action.setCursorToNextLine
      };

    case Editor.createBlockElementWithChildren:
      dom = state.dom;
      newDom = createBlockElementWithChildren(dom, action.tag, action.position, action.offset, action.hash);
      return {
        ...state,
        dom: newDom
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
      newDom = transformBlockElement(dom, action.tag, action.position, action.cleanChildren);
      return {
        ...state,
        dom: newDom
      };

    case Editor.transformBlockElements:
      dom = state.dom;
      newDom = transformBlockElements(dom, action.tag, action.elements);
      return {
        ...state,
        dom: newDom
      };

    case Editor.removeBlockElements:
      dom = state.dom;
      newDom = removeBlockElements(dom, action.map);
      return {
        ...state,
        dom: newDom,
        forceUpdate: true
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
      newDom = handleUnorderedList(dom, action.toList, action.elements, action.parent);
      newDom = _mergeLists(dom);
      return {
        ...state,
        dom: newDom
      };

    case Editor.removeListItemFromList:
      dom = state.dom;
      newDom = removeListItemFromList(dom, action.parentPos, action.childPos);
      return {
        ...state,
        dom: newDom
      };

    case Editor.transformListItemsToBlockElements:
      dom = state.dom;
      newDom = transformListItemsToBlockElements(dom, action.tag, action.depth);
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
      if(state.cursorPosition === undefined) {
        console.log('BIG PROBLEM!', action.position, action.node, action.offset, action.anchorNode);
      }
      return {
        ...state,
        cursorPosition: { 
          pos: action.position, 
          node: action.node,
          offset: action.offset,
          anchorNode: action.anchorNode
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

    case Editor.createCarousel:
      dom = state.dom;
      newDom = handleCarouselCreation(dom, action.map, action.depth);
      return {
        ...state,
        dom: newDom
      };

    case Editor.addImagesToCarousel:
      dom = state.dom;
      newDom = addImagesToCarousel(dom, action.map, action.depth);
      return {
        ...state,
        dom: newDom
      };

    case Editor.deleteImagesFromCarousel:
      dom = state.dom;
      newDom = deleteImagesFromCarousel(dom, action.map, action.depth);
      return {
        ...state,
        dom: newDom
      };

    case Editor.handleVideo:
      dom = state.dom;
      newDom = handleVideo(dom, action.data, action.depth);
      return {
        ...state,
        dom: newDom
      };

    case Editor.createPlaceholderElement:
      dom = state.dom;
      newDom = createPlaceholderElement(dom, action.msg, action.depth);
      return {
        ...state,
        dom: newDom
      };

    default:
      return state;
  };
}

function handleInitialDOM(json) {
  json = json || [];

  if(json.length < 1) {
    let P = {
      tag: 'p',
      content: 'Tell your story...',
      attribs: {
        class: "react-editor-placeholder-text"
      },
      children: []
    }
    json.push(P);
  }

  return json;
}

function handleBlockElementCreation(dom, tag, position) {
  let reactEl = mapToComponent[tag];
  let tagProps = { hash: hashids.encode(Math.floor(Math.random() * 9999 + 1)) };
  let el = reactEl({key: createRandomNumber(), tagProps, children: ['']});

  if(dom.length < 1) {
    dom.push(el);
  } else {
    dom.splice(position+1, 0, el);
  }

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
      console.log('C', child);
      if(child.props.tagProps.hash === hash) {
        target = { position: i, child: child };
        break;
      }

      if(Array.isArray(child.props.children) && child.props.children.length) {
        recurse(child);
      }
    }

  }(rootEl));
  console.log('HI', target, stack);
  return target;
}

function _splitChildren(children, offset, hash) {
  let counter = 0, stack = [], newChildren = children;
  
}

function createBlockElementWithChildren(dom, tag, position, offset, hash) {
  let rootEl = dom[position];
  let children = rootEl.props.children;

  _deepSearchForNodeByHash(rootEl, offset, hash);

  /** Remove any nested spans that contenteditable created on backspace. */
  // if(Array.isArray(children) && typeof children[0] === 'string') {
  //   children = children[0];
  // } else if(Array.isArray(children)) {
  //     children = children.map(child => {
  //       if(child === undefined) {
  //         return '';
  //       } else if(child.type === 'span') {
  //         return child.props.children;
  //       } else {
  //         return child;
  //       }
  //     }).join('');
  // }
  // console.log('LOOK', children);
  // if(typeof children !== 'string') { return dom; }

  // let splitTextByCursor = (function(children, offset) {
  //   return [children.substring(0, offset), children.substring(offset, children.length)];
  // }(children, startOffset));
  
  // // WE NEED TO GET WHAT NODE IS BEING SPLIT AND HONOR THE OTHER NESTED ELS.

  // rootEl = React.cloneElement(rootEl, {}, splitTextByCursor[0]);
  // dom.splice(position, 1, rootEl);

  // let reactEl = mapToComponent[tag];
  // let tagProps = { hash: hashids.encode(Math.floor(Math.random() * 9999 + 1)) };
  // let el = reactEl({key: createRandomNumber(), tagProps, children: splitTextByCursor[1]});
  // dom.splice(position+1, 0, el);

  return dom;
}

function transformBlockElement(dom, tag, position, cleanChildren) {
  let elToReplace = dom[position];

  if(elToReplace !== undefined) {
    let displayName = elToReplace.type.displayName ? elToReplace.type.displayName : elToReplace.type;

    if(tag === displayName.toLowerCase()) { // Revert tag to Paragraph.
      tag = 'p';
    }
    let reactEl = mapToComponent[tag];
    let tagProps = { hash: elToReplace.props.tagProps.hash } || { hash: hashids.encode(Math.floor(Math.random() * 9999 + 1)) };
    let children = cleanChildren === true ? [''] : elToReplace.props.children;
    let el = reactEl({key: createRandomNumber(), tagProps, children: children });

    dom.splice(position, 1, el);
    // If the Element is a PRE and its the last El in the DOM, append a Paragraph below it.
    if(el.type.displayName !== undefined && el.type.displayName.toLowerCase() === 'pre' && position === dom.length-1) {
      dom = appendParagraph(dom);
    }

    return dom;
  }
}

function transformBlockElements(dom, tag, elements) {
  let newDom;
  elements.forEach((element) => {
    /** Prevents any DIV block to be transformed. */
    if(element.nodeName !== 'DIV' && element.nodeName !== 'UL') {
      newDom = transformBlockElement(newDom || dom, tag, element.depth);
    } else if(element.nodeName === 'UL') {
      newDom = transformListItemsToBlockElements(newDom || dom, tag, element.depth);
    }
  });
  return newDom;
}

function cleanElement(dom, position, childPosition) {
  let el = dom[position];
  let childEl = childPosition !== null ? el.props.children[childPosition] : null;
  let children = childPosition !== null ? childEl.props.children : el.props.children;

  /** Remove any nested spans that contenteditable created. */
  if(Array.isArray(children) && typeof children[0] === 'string') {
    children = children[0];
  } else if(Array.isArray(children)) {
      children = children.map(child => {
        if(child === undefined) {
          return '';
        } else if(child.type === 'span') {
          return child.props.children;
        } else {
          return child;
        }
      }).join('');
  }

  if(childEl !== null) {
    childEl = React.cloneElement(childEl, {}, children);
    el.props.children[childPosition] = childEl;
  } else {
    el = React.cloneElement(el, {}, children);
  }

  dom.splice(position, 1, el);
  return dom;
}

function removeBlockElement(dom, position) {
  let newDom = dom;
  newDom.splice(position, 1);
  return newDom;
}

function removeBlockElements(dom, map) {
  let newDom = dom;
  let indexes = _.map(map, function(item) {
    return item.depth;
  });

  let woo = _.pullAt(newDom, indexes); // Mutates newDom; removes indexes.
  
  if(newDom[0] === undefined || newDom.length < 1) {
    newDom = [];
    let P = mapToComponent['p'];
    let tagProps = { hash: hashids.encode(Math.floor(Math.random() * 9999 + 1)) };
    newDom.push( P({key: createRandomNumber(), tagProps, children: ['']}) );
  }
  return newDom;
}

function wrapOrUnwrapBlockElement(dom, tag, position, shouldWrap) {
  let elToReplace = dom[position], tagProps, reactEl, newEl;
  if(shouldWrap) {
    reactEl = mapToComponent[tag];
    tagProps = { hash: elToReplace.props.tagProps.hash } || { hash: hashids.encode(Math.floor(Math.random() * 9999 + 1)) };
    newEl = reactEl({ tagProps, children: elToReplace });
    dom.splice(position, 1, newEl);
  } else {
    reactEl = elToReplace.props.children[0] || elToReplace.props.children;
    dom.splice(position, 1, reactEl);
  }

  return dom;
}

function removeListItemFromList(dom, parentPos, childPos) {
  let newDom = dom;
  let parentEl = newDom[parentPos];
  
  parentEl.props.children = parentEl.props.children.filter(function(child, index) {
    if(index === childPos) {
      return false;
    } else {
      return true;
    }
  });

  newDom.splice(parentPos, 1, parentEl);
  return newDom;
}

function transformListItemsToBlockElements(dom, tag, position) {
  let elToReplace = dom[position];
  let children = elToReplace.props.children;
  let reactEl = mapToComponent[tag], el, tagProps, newChildren;

  // If the UL is wrapped in another block el, this digs into the UL since all we care about is the lis to trasform. 
  if(!Array.isArray(children) && children.type.displayName === 'UL') {
    children = children.props.children;
  }
  console.log('trans item', elToReplace);
  _.forEach(children, function(child, index) {
    if(child !== null && child.type.displayName !== 'DIV') {
      tagProps = index === 0 ? {hash: elToReplace.props.tagProps.hash} : {hash: hashids.encode(Math.floor(Math.random() * 9999 + 1))};
      newChildren = child.props.children;
      el = reactEl({ tagProps, children: newChildren });

      if(index === 0) {
        dom.splice(position+index, 1, el);
      } else {
        dom.splice(position+index, 0, el);
      } 

      // If the Element is a PRE and its the last El in the DOM, append a Paragraph below it.
      if(el.type.displayName !== undefined && el.type.displayName.toLowerCase() === 'pre' && position === dom.length-1) {
        dom = appendParagraph(dom);
      }
    }
  });


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

function handleUnorderedList(dom, toList, elements, parentNode) {
  let children, newChildren, reactEl, tagProps;

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
        el = dom[element.depth - (parentNode.previousLength - 1)];
      } else {
        el = dom[element.depth];
      }
      newChildren = el.props.children;
      return li({ key: createRandomNumber(), children: newChildren });
    });

    reactEl = mapToComponent['ul'];
    tagProps = dom[depth].props.tagProps || { hash: hashids.encode(Math.floor(Math.random() * 9999 + 1)) };
    ul = reactEl({ key: createRandomNumber(), tagProps, children: children });

    dom.splice(depth, elements.length, ul);
  } else {
    let depth = _getNodePositionByHash(dom, parentNode.hash);
    let ul = depth !== undefined ? dom[depth] : dom[parentNode.depth];
    dom = _transformListItems(dom, elements, ul, depth || parentNode.depth);
  }

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
function _mergeLists(dom) {
  let newDom = dom, 
      children = [],
      reactEl = mapToComponent['ul'],
      positionsToMerge = _createPositionsToMerge(newDom, 'UL'),
      UL;

  _.forEach(positionsToMerge, function(position) {
    let parentNodePos = position.shift();
    let parentNode = newDom[parentNodePos];
    children = [];

    _.forEach(position, function(ulPos) {
      children = children.concat(newDom[ulPos].props.children);
    });

    UL = reactEl({tagProps: parentNode.props.tagProps, children: parentNode.props.children.concat(children)});
    newDom.splice(parentNodePos, position.length+1, UL);
  });

  return newDom;
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

function handleCarouselCreation(dom, map, position) {
  let carousel, inner, children = [];

  _.forEach(map, function(image, index) {
    if(index === 0) {
      if(map.length > 1) {
        carousel = createCarousel(dom, image.url, image.width, position, true);
      } else {
        carousel = createCarousel(dom, image.url, image.width, position);
      }

    } else {
      if(map.length > 1 && index === map.length-1) {
        children.push(createImage(image.url, image.width));
      } else {
        children.push(createImage(image.url, image.width));
      }
    }
  });

  inner = carousel.props.children[0];
  inner.props.children.push(...children);
  dom.splice(position, 1, carousel);

  // Append a Paragraph if the carousel is the last element.
  if(position === dom.length-1) {
    dom = appendParagraph(dom);
  }

  return dom;
}

function createCarousel(dom, imgSrc, imgWidth, position) {
  let newDom = dom;
  let elToReplace = newDom[position] || { props: {tagProps: { hash: hashids.encode(Math.floor(Math.random() * 9999 + 1))}} };
  let Figure = mapToComponent['figure'];
  let Img = mapToComponent['img'];
  let Div = mapToComponent['div'];
  let FigCaption = mapToComponent['figcaption'];
  let Carousel = mapToComponent['carousel'];
  let FIGURE, IMG, FIGCAPTION, DIV, CAROUSEL, INNERCAROUSEL;

  FIGCAPTION = FigCaption({
    tagProps: {},
    style: {},
    className: 'react-editor-figcaption',
    key: createRandomNumber(), 
    children: ['caption (optional)']
  });
  
  IMG = Img({
    tagProps: { src: imgSrc, 'data-src': '', alt: ''},
    style: { width: imgWidth },
    className: 'react-editor-image', 
    key: createRandomNumber(), 
    children: []
  });

  DIV = Div({
    tagProps: {},
    className: 'react-editor-image-wrapper',
    key: createRandomNumber(),
    children: [IMG, FIGCAPTION]
  });

  FIGURE = Figure({
    tagProps: { hash: hashids.encode(Math.floor(Math.random() * 9999 + 1)), 'data-type': 'image' },
    className: 'react-editor-figure show', 
    key: createRandomNumber(), 
    children: [DIV]
  });

  INNERCAROUSEL = Div({
    tagProps: {},
    style: {},
    className: 'react-editor-carousel-inner',
    key: createRandomNumber(),
    children: [FIGURE]
  });

  CAROUSEL = Carousel({
    tagProps: { hash: elToReplace.props.tagProps.hash, 'data-type': 'carousel' },
    className: 'react-editor-carousel',
    key: createRandomNumber(),
    children: [INNERCAROUSEL]
  });

  return CAROUSEL;
}

function addImagesToCarousel(dom, map, position) {
  let carousel = dom[position];
  let inner = carousel.props.children[0];
  let images = _.map(map, function(image) {
    return createImage(image.url, image.width);
  });

  /** Remove the class 'show' from current shown */
  let newChildren = _.map(inner.props.children, function(figure) {
    if(figure && figure.props.className.split(' ').indexOf('show') === 1) {
      return React.cloneElement(figure, {className: 'react-editor-figure'});
    } else {
      return React.cloneElement(figure);
    }
   });

  images[images.length-1] = React.cloneElement(images[images.length-1], {className: 'react-editor-figure show'});
  newChildren.push(...images);
  inner = React.cloneElement(inner, {}, [...newChildren]);
  carousel = React.cloneElement(carousel, {}, [inner]);

  dom.splice(position, 1, carousel);
  return dom;
}

function createImage(imgSrc, imgWidth) {
  let Figure = mapToComponent['figure'];
  let Img = mapToComponent['img'];
  let Div = mapToComponent['div'];
  let FigCaption = mapToComponent['figcaption'];
  let FIGURE, IMG, FIGCAPTION, DIV;

  FIGCAPTION = FigCaption({
    tagProps: {},
    style: { width: imgWidth },
    className: 'react-editor-figcaption',
    key: createRandomNumber(), 
    children: ['caption (optional)']
  });
  
  IMG = Img({
    tagProps: { src: imgSrc, 'data-src': '', alt: ''},
    style: { width: imgWidth },
    className: 'react-editor-image', 
    key: createRandomNumber(), 
    children: []
  });

  DIV = Div({
    tagProps: {},
    className: 'react-editor-image-wrapper',
    key: createRandomNumber(),
    children: [IMG, FIGCAPTION]
  });

  FIGURE = Figure({
    tagProps: { hash: hashids.encode(Math.floor(Math.random() * 9999 + 1)), 'data-type': 'image' },
    className: 'react-editor-figure',
    key: createRandomNumber(), 
    children: [DIV]
  });

  return FIGURE;
}

function deleteImagesFromCarousel(dom, map, position) {
  let carousel = dom[position];
  let inner = carousel.props.children[0];
  let replaceShownImage = false;
  let newChildren, indexOfShown;

  if(map.length < 1) {
    newChildren = _.filter(inner.props.children, function(figure, index) {
      if(figure.props.className.split(' ').indexOf('show') === 1) {
        replaceShownImage = true;
        indexOfShown = index;
        return false;
      } else {
        return true;
      }
    });
  } else {
    newChildren = _.filter(inner.props.children, function(figure, index) {
      if(_.includes(map, figure)) {
        if(figure.props.className.split(' ').indexOf('show') === 1) {
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
  if(newChildren.length < 1) {
    return removeBlockElement(dom, position);
  }

  if(replaceShownImage) {
    indexOfShown = (indexOfShown - 1) < 0 ? 0 : (indexOfShown-1);
    newChildren[indexOfShown] = React.cloneElement(newChildren[indexOfShown], {className: 'react-editor-figure show'});
  }

  inner = React.cloneElement(inner, {}, newChildren);
  carousel = React.cloneElement(carousel, {}, [inner]);

  dom.splice(position, 1, carousel);
  return dom;
}

function handleVideo(dom, data, position) {
  let elToReplace = dom[position] || {props: {tagProps: { hash: hashids.encode(Math.floor(Math.random() * 9999 + 1)) }}};
  let Video = mapToComponent['video'];
  let Div = mapToComponent['div'];
  let FIGURE = createImage(data.url, data.width);
  let INNERVIDEO, VIDEO, VIDEOMASK;

  VIDEOMASK = Div({
    tagProps: {},
    style: {},
    className: 'video-mask fa fa-youtube-play',
    key: createRandomNumber(),
    children: []
  });

  INNERVIDEO = Div({
    tagProps: {},
    style: {},
    className: 'react-editor-video-inner',
    key: createRandomNumber(),
    children: [VIDEOMASK, FIGURE]
  });

  VIDEO = Video({
    tagProps: { hash: elToReplace.props.tagProps.hash, 'data-video-id': data.id },
    className: 'react-editor-video',
    key: createRandomNumber(),
    children: [INNERVIDEO]
  });

  dom.splice(position, 1, VIDEO);

  if(position === dom.length-1) {
    dom = appendParagraph(dom);
  }

  return dom;
}

function appendParagraph(dom) {
  let P = mapToComponent['p'];
  let tagProps = { hash: hashids.encode(Math.floor(Math.random() * 9999 + 1)) };
  dom.push( P({ key: createRandomNumber(), tagProps, children: [''] }) );

  return dom;
}

function createPlaceholderElement(dom, msg, position) {
  let P = mapToComponent['p'];
  let tagProps = { hash: hashids.encode(Math.floor(Math.random() * 9999 + 1)) };
  let el = P({ key: createRandomNumber(), tagProps, className: 'react-editor-placeholder-text', children: [msg] });

  dom.splice(position, 1, el);
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
      // TODO: CAMEL CASE ANY HYPHENED STYLE HERE!!!!!!!
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

function createArrayOfComponents(dom) {
  return (function recurse(source, lastHash) {
    lastHash = lastHash || null;
    return source.map(function(item, index) {
      
      /** Safety Check */
      if(item === undefined || item.tag === 'br') {
        return null;
      }

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
    });
  }(dom));
}

