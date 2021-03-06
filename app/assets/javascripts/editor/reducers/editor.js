import React from 'react';
import _ from 'lodash';
import { Editor } from '../constants/ActionTypes';
import Utils from '../utils/DOMUtils';
import Helpers from '../../utils/Helpers';
import { ErrorIcons, BlockElements } from '../utils/Constants';
import BlockModel from '../models/Block';
import Parser from '../utils/Parser';

import Hashids from 'hashids';
const hashids = new Hashids('hackster', 4);

const initialState = {
  dom: [],
  hasUnsavedChanges: false,
  isFetching: false,
  currentStoreIndex: 0,
  projectId: null,
  modelType: null,
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
  errorMessenger: { show: false, msg: '', type: '' },
  lastMediaHash: null,
  isIE: false,
  updateComponent: null,
  domUpdated: false,
  replaceLastInUndoStore: false
};

export default function(state = initialState, action) {
  let dom, newDom, cursorPosition, mediaHash, rootHash, obj, data, cursorData;
  switch (action.type) {

    case Editor.setDOM:
      dom = state.dom;
      newDom = updateComponentAtIndex(dom, action.html, action.storeIndex, action.depth);
      return {
        ...state,
        dom: newDom || state.dom,
        domUpdated: true,
        cursorPosition: { ...action.cursorData }
      };

    case Editor.domUpdated:
      return {
        ...state,
        domUpdated: action.bool
      };

    case Editor.setEditorState:
      return action.state;

    case Editor.hasUnsavedChanges:
      return {
        ...state,
        hasUnsavedChanges: action.bool
      };

    case Editor.setInitialDOM:
      newDom = handleInitialDOM(action.json);
      newDom = _insertPlaceholder(newDom);
      return {
        ...state,
        dom: newDom || state.dom,
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
        projectId: action.projectId,
        modelType: action.modelType,
        S3BucketURL: action.S3BucketURL,
        AWSAccessKeyId: action.AWSAccessKeyId
      };

    case Editor.createBlockElement:
      dom = state.dom;
      newDom = createBlockElement(dom, action.tag, action.position, action.storeIndex);
      return {
        ...state,
        dom: newDom || state.dom,
        setCursorToNextLine: action.setCursorToNextLine,
        domUpdated: true
      };

    case Editor.createBlockElementWithChildren:
      dom = state.dom;
      newDom = createBlockElementWithChildren(dom, action.children, action.tag, action.position, action.storeIndex);
      return {
        ...state,
        dom: newDom || state.dom,
        setCursorToNextLine: action.setCursorToNextLine,
        domUpdated: true
      };

    case Editor.transformBlockElement:
      dom = state.dom;
      newDom = transformBlockElement(dom, action.tag, action.position, action.cleanChildren, action.storeIndex);
      return {
        ...state,
        dom: newDom || state.dom,
        domUpdated: true
      };

    case Editor.transformBlockElements:
      dom = state.dom;
      newDom = transformBlockElements(dom, action.tag, action.elements, action.storeIndex);
      return {
        ...state,
        dom: newDom || state.dom,
        domUpdated: true
      };

    case Editor.prependCE:
      dom = state.dom;
      newDom = prependCE(dom, action.storeIndex);
      return {
        ...state,
        dom: newDom || state.dom,
        domUpdated: true
      };

    case Editor.insertCE:
      dom = state.dom;
      obj = insertCE(dom, action.storeIndex);
      newDom = _mergeAdjacentCE(obj.newDom);
      return {
        ...state,
        dom: newDom || state.dom,
        cursorPosition: {
          ...state.cursorPosition,
          rootHash: obj.rootHash
        },
        setCursorToNextLine: false,
        domUpdated: true
      };

    case Editor.setFigCaptionText:
      dom = state.dom;
      newDom = setFigCaptionText(dom, action.figureIndex, action.storeIndex, action.html);
      return {
        ...state,
        dom: newDom || state.dom,
        domUpdated: true
      }

    case Editor.handleUnorderedList:
      dom = state.dom;
      newDom = handleUnorderedList(dom, action.toList, action.elements, action.parent, action.storeIndex);
      newDom = _mergeLists(newDom, action.storeIndex);
      return {
        ...state,
        dom: newDom || state.dom,
        domUpdated: true
      };

    case Editor.removeListItemFromList:
      dom = state.dom;
      newDom = removeListItemFromList(dom, action.parentPos, action.childPos, action.storeIndex);
      return {
        ...state,
        dom: newDom || state.dom,
        domUpdated: true
      };

    case Editor.transformListItemsToBlockElements:
      dom = state.dom;
      newDom = transformListItemsToBlockElements(dom, action.tag, action.depth, action.storeIndex);
      return {
        ...state,
        dom: newDom || state.dom,
        domUpdated: true
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
      data = handleMediaCreation(dom, action.map, action.depth, action.storeIndex, action.mediaType);
      newDom = _mergeAdjacentCE(data.newDom);
      newDom = _insertPlaceholder(newDom);
      return {
        ...state,
        dom: newDom || state.dom,
        cursorPosition: data.cursorPosition,
        setCursorToNextLine: false,
        lastMediaHash: data.mediaHash,
        forceUpdate: true,
        domUpdated: true
      };

    case Editor.addImagesToCarousel:
      dom = state.dom;
      newDom = addImagesToCarousel(dom, action.map, action.storeIndex);
      return {
        ...state,
        dom: newDom || state.dom,
        domUpdated: true
      };

    case Editor.deleteImagesFromCarousel:
      dom = state.dom;
      newDom = deleteImagesFromCarousel(dom, action.map, action.depth, action.storeIndex);
      newDom = _mergeAdjacentCE(newDom);
      newDom = _insertPlaceholder(newDom);
      return {
        ...state,
        dom: newDom || state.dom,
        domUpdated: true
      };

    case Editor.updateShownImage:
      dom = state.dom;
      newDom = updateShownImage(dom, action.activeIndex, action.storeIndex, action.direction);
      return {
        ...state,
        dom: newDom || state.dom
      };

    case Editor.deleteComponent:
      dom = state.dom;
      newDom = deleteComponent(dom, action.storeIndex);
      newDom = _mergeAdjacentCE(newDom);
      newDom = _insertPlaceholder(newDom);
      return {
        ...state,
        dom: newDom || state.dom,
        forceUpdate: true,
        domUpdated: true
      };

    case Editor.createPlaceholderElement:
      dom = state.dom;
      newDom = createPlaceholderElement(dom, action.element, action.depth, action.storeIndex);
      return {
        ...state,
        dom: newDom || state.dom,
        domUpdated: true
      };

    case Editor.resetImageUrl:
      mediaHash = action.mediaHash || state.lastMediaHash;
      dom = state.dom;
      newDom = resetImageUrl(dom, action.imageData, mediaHash, action.storeIndex);
      return {
        ...state,
        dom: newDom || state.dom,
        isDataLoading: false,
        replaceLastInUndoStore: true
      };

    case Editor.removeImageFromList:
      mediaHash = action.mediaHash || state.lastMediaHash;
      dom = state.dom;
      newDom = removeImageFromList(dom, action.imageData, mediaHash, action.storeIndex);
      return {
        ...state,
        dom: newDom || state.dom,
        domUpdated: true
      };

    case Editor.isDataLoading:
      return {
        ...state,
        isDataLoading: action.bool
      };

    case Editor.splitBlockElement:
      dom = state.dom;
      newDom = splitBlockElement(dom, action.tagType, action.nodes, action.depth, action.storeIndex);
      return {
        ...state,
        dom: newDom || state.dom,
        domUpdated: true
      };

    case Editor.toggleErrorMessenger:
      let errorMessenger = { show: action.show, msg: action.msg, type: action.msgType };
      return {
        ...state,
        errorMessenger: errorMessenger
      };

    case Editor.handlePastedHTML:
      dom = state.dom;
      data = handlePastedHTML(dom, action.html, action.depth, action.storeIndex, action.endDepth, action.cursorData);
      newDom = _mergeAdjacentCE(data.newDom);
      newDom = _insertPlaceholder(newDom);
      return {
        ...state,
        dom: newDom || state.dom,
        cursorPosition: data.cursorPosition,
        domUpdated: true
      };

    case Editor.toggleIE:
      return {
        ...state,
        isIE: action.bool
      };

    case Editor.transformInlineToText:
      dom = state.dom;
      newDom = transformInlineToText(dom, action.text, action.depth, action.storeIndex);
      return {
        ...state,
        dom: newDom || state.dom,
        domUpdated: true
      };

    case Editor.updateCarouselImages:
      dom = state.dom;
      newDom = updateCarouselImages(dom, action.images, action.storeIndex);
      return {
        ...state,
        dom: newDom || state.dom,
        domUpdated: true
      };

    case Editor.updateComponent:
      return {
        ...state,
        updateComponent: action.storeIndex
      };

    case Editor.setState:
      return { ...action.state };

    case Editor.toggleFlag:
      return {
        ...state,
        [action.flag]: action.bool
      };

    default:
      return state;
  };
}

function updateComponentAtIndex(dom, json, index, depth) {
  let component = dom[index];
  component.json = json;

  if(component.type === 'CE') {
    component.html = Parser.toHtml(component.json);
  }

  dom.splice(index, 1, component);
  return dom;
}

function handleInitialDOM(json) {
  json = json || [];

  if(json.length < 1) {
    let CE = {
      type: 'CE',
      hash: hashids.encode(Math.floor(Math.random() * 9999 + 1)),
      json: [_createElement('p', {
        attribs: { 'data-hash': _createNewHash(), class: 'react-editor-placeholder-text' },
        children: [ _createElement('br') ]
      })]
    };

    CE.html = Parser.toHtml(CE.json);
    json.push(CE);
  } else {
    json = json.map(item => {
      if(item.type === 'CE') {
        /** Create new Pre Blocks on newlines.
          * Unmerge the Pres that we merged and sent to the server.
         */
        if(item.json.length > 0) {
          item.json = _unmergePreBlocks(item.json);
        }

        if(item.json.length < 1) {
          item.json.push(_createElement('p'));
        }
        let CE = {
          hash: item.hash,
          type: item.type,
          json: _sweepInitialJson(item.json)
        };

        CE.html = Parser.toHtml(CE.json);
        return CE;
      } else if(item.type === 'Carousel') {
        if(item.images.length < 1) { return null; }
        item.images[0].show = true;
        return item;
      } else {
        return item;
      }
    }).filter(item => item !== null);
  }
  return json;
}

function _sweepInitialJson(json) {
  return json.map(item => {

    if(!item.attribs['data-hash']) {
      item.attribs['data-hash'] = _createNewHash();
    }

    if((!item.content || item.content.length < 1) && item.children.length < 1) {
      item.children.push(_createElement('br'));
    }

    return item;
  });
}

function _hashifyBlockElements(json) {
  return json.map(item => {
    if(!item.attribs['data-hash']) {
      item.attribs['data-hash'] = _createNewHash();
    }
    return item;
  });
}

function _unmergePreBlocks(json) {
  let newJson = [];

  json.forEach(item => {
    if(item.tag === 'pre' && item.children.length > 0) {
      let children = item.children[0].tag === 'code' && item.children[0].children.length > 0 ? item.children[0].children : item.children;
      children.forEach(child => {
        /** Remove new lines at the end of each row. */
        if(child.content && child.content.substr(child.content.length-1) === '\n') {
          child.content = child.content.replace(/\n/g, '');
        }
        if(child.content && child.content.length < 1) {
          child.children.push( _createElement('br') );
        }

        let code = _createElement('code', { children: [ child ] });
        let pre = _createElement('pre', { children: [ code ] });
        newJson.push(pre);
      });
    } else {
      newJson.push(item);
    }
  });
return newJson;
}

function _createElement(tag, options) {
  options = options === Object(options) ? options : {};
  let hash = BlockElements[tag.toUpperCase()]
           ? options.attribs && options.attribs['data-hash'] ? options.attribs['data-hash'] : _createNewHash()
           : '';

  return {
    attribs: options.attribs ? { ...options.attribs, 'data-hash': hash } : hash.length ? { 'data-hash': hash } : {},
    children: options.children || [],
    content: options.content || '',
    tag: tag,
  };
}

function _createNewHash() {
  return hashids.encode(Math.floor(Math.random() * 9999 + 1));
};

/**
 * Block Elements
 */

function createBlockElement(dom, tag, position, storeIndex) {
  let component = dom[storeIndex];
  let json = component.json;
  let el = _createElement(tag, { children: [_createElement('br')] });

  if(json.length < 1) {
    json.push(el);
  } else {
    json.splice(position+1, 0, el);
  }

  component.json = json;
  component.html = Parser.toHtml(component.json);
  dom.splice(storeIndex, 1, component);
  return dom;
}

function createBlockElementWithChildren(dom, children, tag, position, storeIndex) {
  let component = dom[storeIndex];
  let json = component.json;
  let currentEl = _createElement(tag, { children: children.htmlToKeep, attribs: { 'data-hash': json[position].attribs['data-hash'] }});
  let newEl = _createElement(tag, {
    children:  BlockModel.doesChildrenHaveText(children.htmlToAppend) ? children.htmlToAppend : [ _createElement('br') ]
  });

  json.splice(position, 1, currentEl);
  json.splice(position+1, 0, newEl);
  component.json = json;
  component.html = Parser.toHtml(component.json);
  dom.splice(storeIndex, 1, component);

  return dom;
}

function transformBlockElement(dom, tag, position, cleanChildren, storeIndex) {
  let component = dom[storeIndex];
  let elToReplace = component.json[position];
  let children, el;

  if(!elToReplace) { return dom; }

  /** Basic 'UNDO', reverts tag to p. */
  tag = tag === elToReplace.tag ? 'p' : tag;
  children = cleanChildren || elToReplace.children.length < 1 ? [ _createElement('br') ] : elToReplace.children;

  el = tag === 'h3'
     ? _createElement(tag, { attribs: { ['data-hash']: elToReplace.attribs['data-hash' ] }, content: BlockModel.getTextContent([elToReplace]) })
     : _createElement(tag, { attribs: { ['data-hash']: elToReplace.attribs['data-hash' ] }, content: elToReplace.content, children: children });
  component.json.splice(position, 1, el);

  /** If the Element is a PRE and its the last El in the DOM, append a Paragraph below it. */
  if(el.tag === 'pre' && position === component.json.length-1) {
    component.json.push(_createElement('p'));
  }

  component.html = Parser.toHtml(component.json);
  dom.splice(storeIndex, 1, component);
  return dom;
}

function transformBlockElements(dom, tag, elements, storeIndex) {
  let newDom;

  elements.forEach((element) => {
    if(element.nodeName !== 'UL') {
      newDom = transformBlockElement(newDom || dom, tag, element.depth, false, storeIndex);
    } else {
      newDom = transformListItemsToBlockElements(newDom || dom, tag, element.depth, storeIndex);
    }
  });
  return newDom;
}

function transformListItemsToBlockElements(dom, tag, position, storeIndex) {
  let component = dom[storeIndex];
  let json = component.json;
  let elToReplace = json[position];
  let el;

  elToReplace.children.forEach((child, index) => {
    el = _createElement(tag, {
      attribs: { 'data-hash': index === 0 ? elToReplace.attribs['data-hash'] : _createNewHash() },
      content: BlockModel.getTextContent([child])
    });

    if(index === 0) {
      json.splice(position+index, 1, el);
    } else {
      json.splice(position+index, 0, el);
    }
  });

  component.json = json;
  component.html = Parser.toHtml(component.json);
  dom.splice(storeIndex, 1, component);
  return dom;
}

function splitBlockElement(dom, tagType, nodes, depth, storeIndex) {
  let component = dom[storeIndex];
  let json = component.json;
  let prevTag = json[depth].tag;

  let top = _createElement(prevTag, { attribs: { ['data-hash']: json[depth].attribs['data-hash'] }, children: nodes.shift() });
  json.splice(depth, 1, top);

  let middle = _createElement(tagType, { children: nodes.shift() });
  json.splice(depth+1, 0, middle);

  if(nodes[0].length) {
    let bottom = _createElement(prevTag, { children: nodes.shift() });
    json.splice(depth+2, 0, bottom);
  }

  component.json = json;
  component.html = Parser.toHtml(component.json);
  dom.splice(storeIndex, 1, component);
  return dom;
}

/**
 * Inline Elements.
 */
function transformInlineToText(dom, newJson, depth, storeIndex) {
  let component = dom[storeIndex];
  let json = component.json;
  json.splice(depth, 1, newJson[0]);

  component.json = json;
  component.html = Parser.toHtml(component.json);
  dom.splice(storeIndex, 1, component);
  return dom;
}

/**
 * List Items
 */
function handleUnorderedList(dom, toList, elements, depthData, storeIndex) {
  let component = dom[storeIndex];
  let json = component.json;

  if(toList) {
    json.splice(depthData.startDepth, depthData.itemsToRemove, elements);
  } else {
    elements.forEach((element, index)=> {
      element.node.attribs['data-hash'] = element.node.attribs['data-hash'] ? element.node.attribs['data-hash'] : _createNewHash();
      json.splice(element.listDepth+index, index === 0 ? 1 : 0, element.node);
    });
  }

  component.json = json;
  component.html = Parser.toHtml(component.json);
  dom.splice(storeIndex, 1, component);
  return dom;
}

function removeListItemFromList(dom, parentPos, childPos, storeIndex) {
  let component = dom[storeIndex];
  let json = component.json;
  let parentEl = json[parentPos];
  let filteredChildren = parentEl.children.filter((child, index) => {
    if(index === childPos) {
      return false;
    } else {
      return true;
    }
  });

  parentEl.children = filteredChildren;
  json.splice(parentPos, 1, parentEl);

  component.json = json;
  component.html = Parser.toHtml(component.json);
  dom.splice(storeIndex, 1, component);
  return dom;
}

/**
 * Runs after everyafter every handleUnorderedList.
 * It checks if theres ULs above and below the list currently being created.
 */
function _mergeLists(dom, storeIndex) {
  let component = dom[storeIndex],
      json = component.json;

  json = json.reduce((prev, curr) => {
    if(prev.length > 0 && prev[prev.length-1].tag === 'ul' && curr.tag === 'ul') {
      prev[prev.length-1].children.push(...curr.children);
    } else {
      prev.push(curr);
    }
    return prev;
  }, []);

  component.json = json;
  component.html = Parser.toHtml(component.json);
  dom.splice(storeIndex, 1, component);
  return dom;
}

function prependCE(dom, storeIndex) {
  let CE = _createCE();

  /** We either add a CE or append a Paragraph to the previous CE. */
  if(storeIndex === 0 || dom[storeIndex-1].type !== 'CE') {
    dom.splice(storeIndex, 0, CE);
  } else {
    let component = dom[storeIndex-1];
    component.json.push(CE.json[0]);
    component.html = Parser.toHtml(component.json);
    dom.splice(storeIndex-1, 1, component);
  }

  return dom;
}

function insertCE(dom, storeIndex) {
  let CE = _createCE();

  dom.splice(storeIndex, 1, CE);
  return { newDom: dom, rootHash: CE.hash };
}

function _createCE(hash, pHash) {
  let CE = {
    type: 'CE',
    json: [ _createEmptyParagraph(pHash || null) ],
    hash: hash || _createNewHash()
  };
  CE.html = Parser.toHtml(CE.json);
  return CE;
}

function _createEmptyParagraph(hash) {
  return _createElement('p', {
    attribs: { 'data-hash': hash || _createNewHash() },
    children: [ _createElement('br') ]
  });
}

function setFigCaptionText(dom, figureIndex, storeIndex, html) {
  let component = dom[storeIndex];

  /** If images, it's a Carousel, else a Video. */
  if(component.images) {
    let images = component.images;
    images[figureIndex].figcaption = html;

    component.images = images;
  } else {
    let video = component.video;
    video[0].figcaption = html;

    component.video = video;
  }

  dom.splice(storeIndex, 1, component);
  return dom;
}

function handleMediaCreation(dom, map, depth, storeIndex, mediaType) {
  let component = dom[storeIndex];
  let json = component.json;
  let media = mediaType === 'Carousel'
            ? {
                type: mediaType,
                images: map,
                hash: _createNewHash()
              }
            : mediaType === 'Video'
            ? {
                type: mediaType,
                video: map,
                hash: _createNewHash()
              }
            : {
              type: mediaType,
              data: map,
              hash: _createNewHash()
            };
  let mediaHash = media.hash;
  let cursorPosition = { pos: 0, node: null, offset: 0, anchorNode: null, rootHash: null };
  let newNodeForCursor;

  /** Sets the first image to show. */
  if(media.images) {
    media.images[0].show = true;
  }
  /**
    * If we're adding a Media block to the end of a CE.
    * Else if we're at the top of a CE, remove the current line and prepend the media block.
    * Else we need to splice the content of the CE by depth.
   */
  if(depth === json.length-1) {
    let currNode = json.pop();
    let CE = {
      type: 'CE',
      json: [ _createElement('p', {
        attribs: { 'data-hash': _createNewHash() },
        children: (mediaType === 'Carousel' && (currNode.content.length || currNode.children.length)) ? [currNode] : [ _createElement('br') ]
      })],
      hash: _createNewHash()
    };

    if(json.length < 1) {
      json.push( _createEmptyParagraph() );
    }

    component.json = json;
    component.html = Parser.toHtml(component.json);
    CE.html = Parser.toHtml(CE.json);

    dom.splice(storeIndex, 1, component);
    dom.splice(storeIndex+1, 0, media);
    dom.splice(storeIndex+2, 0, CE);

    newNodeForCursor = Parser.toHtml([CE.json[0]]);
    newNodeForCursor = Parser.toLiveHtml(newNodeForCursor);
    cursorPosition = { ...cursorPosition, node: newNodeForCursor, anchorNode: newNodeForCursor, rootHash: CE.hash };
  } else if(depth === 0 && json[depth+1] && json[depth+1].children) {
    /** Remove the line if it was a video url. */
    if(mediaType === 'Video') {
      json.splice(depth, 1);
    }

    component.json = json;
    component.html = Parser.toHtml(component.json);
    /** This will place the media block above the component. */
    dom.splice(storeIndex, 1, media);
    dom.splice(storeIndex+1, 0, component);

    newNodeForCursor = Parser.toHtml([component.json[0]]);
    newNodeForCursor = Parser.toLiveHtml(newNodeForCursor);
    cursorPosition = { ...cursorPosition, node: newNodeForCursor, anchorNode: newNodeForCursor, rootHash: component.hash };
  } else {
    // If the mediaType is a video, ignore the current line.
    let bottomDepthStart = mediaType === 'Video'? depth+1 : depth;
    let top = json.slice(0, depth);
    let bottom = json.slice(bottomDepthStart);
    let topCE = { type: 'CE', hash: component.hash, json: top, html: Parser.toHtml(top) };
    let bottomCE = { type: 'CE', hash: _createNewHash(), json: bottom, html: Parser.toHtml(bottom) };

    dom.splice(storeIndex, 1, topCE);
    dom.splice(storeIndex+1, 0, media);
    dom.splice(storeIndex+2, 0, bottomCE);

    newNodeForCursor = Parser.toHtml([bottomCE.json[0]]);
    newNodeForCursor = Parser.toLiveHtml(newNodeForCursor);
    cursorPosition = { ...cursorPosition, node: newNodeForCursor, anchorNode: newNodeForCursor, rootHash: bottomCE.hash };
  }

  return { newDom: dom, cursorPosition: cursorPosition, mediaHash: mediaHash };
}

function addImagesToCarousel(dom, map, storeIndex) {
  let component = dom[storeIndex];
  let images = component.images;
  let newImages = map.map(image => {
    return { url: image.url, alt: image.alt, figcaption: null, uuid: image.uuid };
  });

  /** Remove current shown image and show the last image added. */
  images.forEach(image => {
    if(image.show) {
      image.show = false;
    }
  });
  newImages[newImages.length-1].show = true;

  images.push(...newImages);
  component.images = images;
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
  let images = component.images || component.video;
  let replaceShownImage = false;
  let newImages, indexOfShown;

  /** If we're deleting one image, its the one shown.
    * Else we look for it.
  */
  if(map.length < 1) {
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
    dom.splice(storeIndex, 1, _createCE(component.hash));
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
      newDom[newDom.length-1].html = Parser.toHtml(newDom[newDom.length-1].json);
    } else {
      newDom.push(component);
    }
  });

  return newDom;
}

function _insertPlaceholder(dom) {
  let newDom = [];

  dom.forEach((component, index) => {
    let mediaTypes = {
      'Carousel': true,
      'Video': true,
      'File': true,
      'WidgetPlaceholder': true
    };

    if(mediaTypes[component.type] && (index > 0 && mediaTypes[dom[index-1].type])) {
      newDom.push(_createPlaceholderComponent());
      newDom.push(component);
    } else if(index > 0 && component.type === 'Placeholder' && (!mediaTypes[dom[index-1].type] || (dom[index+1] && !mediaTypes[dom[index+1].type]))) {
      /** Removes unneccessary placeholders */
      return;
    } else {
      newDom.push(component);
    }
  });

  return newDom;
}

function _createPlaceholderComponent() {
  return {
    type: 'Placeholder',
    hash: _createNewHash()
  };
}

function deleteComponent(dom, storeIndex) {
  dom.splice(storeIndex, 1);
  return dom;
}

function resetImageUrl(dom, data, mediaHash, storeIndex) {
  let component = dom[storeIndex];
  /** Make sure we have the correct block. */
  if(component.type !== 'Carousel' && component.hash !== mediaHash) {
    dom.forEach((item, index) => {
      if(item.hash === mediaHash) {
        component = item;
        storeIndex = index;
      }
    });
  }

  let images = component.images;
  let newImages = images.map(image => {
    if(image.uuid === data.uuid) {
      image.id = data.id;
      return image;
    } else {
      return image;
    }
  });

  component.images = newImages;
  dom.splice(storeIndex, 1, component);
  return dom;
}

function removeImageFromList(dom, data, mediaHash, storeIndex) {
  let component = dom[storeIndex];

  /** Make sure we have the correct block. */
  if(component.type !== 'Carousel' && component.hash !== mediaHash) {
    dom.forEach((item, index) => {
      if(item.hash === mediaHash) {
        component = item;
        storeIndex = index;
      }
    });
  }

  let images = component.images.filter(image => {
    if(image.uuid === data.uuid) {
      return false;
    } else {
      return true;
    }
  });

  dom.splice(storeIndex, 1, component);
  return dom;
}

function updateCarouselImages(dom, images, storeIndex) {
  let component = dom[storeIndex];
  component.images = images;
  dom.splice(storeIndex, 1, component);
  return dom;
}

function createPlaceholderElement(dom, element, position, storeIndex) {
  let component = dom[storeIndex];
  let json = component.json;
  let replaceLine = 1;

  if( (json[position].children && json[position].children.length > 0 && json[position].children[0].tag !== 'br') ||
      (json[position].content && json[position].content.length > 0) ) {
    replaceLine = 0;
    position += 1;
  }

  json.splice(position, replaceLine, element);
  component.json = json;
  component.html = Parser.toHtml(component.json);
  dom.splice(storeIndex, 1, component);
  return dom;
}

function handlePastedHTML(dom, html, depth, storeIndex, endDepth, cursorData) {
  let cursorPosition = { pos: depth, node: null, offset: 0, anchorNode: null, rootHash: null };
  let component = dom[storeIndex];
  let json = component.json;
  endDepth = endDepth <= depth ? depth : endDepth;

  html.json = html.json.map(item => {
    if(!item.attribs || !item.attribs['data-hash']) {
      item.attribs = { 'data-hash': _createNewHash() };
    }
    return item;
  });

  let start = json.slice(0, depth);
  let end = json[endDepth+1] !== undefined ? json.slice(endDepth+1) : [];
  let newJson = start.concat(html.json.concat(end));

  component.json = newJson;
  component.html = Parser.toHtml(component.json);
  dom.splice(storeIndex, 1, component);

  return { newDom: dom, cursorPosition: { ...cursorPosition, node: cursorData.node, anchorNode: cursorData.anchorNode, offset: cursorData.offset, rootHash: component.hash } };
}

function randomizeErrorActionIcon() {
  const icons = ErrorIcons;
  let random = Math.floor(Math.random() * icons.length);
  return icons[random];
}