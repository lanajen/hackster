import _ from 'lodash';
import Hashids from 'hashids';
const hashids = new Hashids('hackster', 4);

export default {
  /**
   * Creates a list block element, json format.
   * @param  {[array]} nodes [{ json: [array], hash: [string], depth: [int] }, {etc}]
   */
  toList(nodes) {
    let children = nodes.map(node => {
      if(node.json[0].tag === 'ul') {
        return node.json[0].children;
      } else {
        return { ...node.json[0], tag: 'li', attribs: {} };
      }
    });

    return {
      attribs: { 'data-hash': nodes[0].hash },
      children: _.flatten(children),
      content: '',
      tag: 'ul'
    };
  },

  createULGroups(startContainer, endContainer, parentNode) {
    let groups = [], group = [], cont = false, child;

    for(let i = 0; i < parentNode.children.length; i++) {
      child = parentNode.children[i];

      if(child === startContainer || cont === true) {
        cont = true;
        group.push({ node: child, depth: i, hash: child.getAttribute('data-hash') });
      }

      if(child === endContainer) {
        cont = false;
        groups.push(group);
        break;
      }
    }

    return groups[0];
  },

  createList(options) {
    options = options === Object(options) ? options : {};
    return {
      attribs: options.attribs || {},
      children: options.children || [],
      content: options.content || '',
      tag: options.tag || 'ul'
    };
  },

  /**
   * Transforms list items into paragraphs where selected.  Splits and recreates the lists accordingly.
   *
   * @param  {[array]} json                   [Parsed html of the current list]
   * @param  {[array]} childDepthsToTransform [Depths of selected list items]
   * @param  {[int]} listDepth              [Depth of list in the current Content Editable]
   * @return {[array]}                        [Map of depth/positions and built nodes to splice in Content Editable]
   */
  transformListItems(json, childDepthsToTransform, listDepth) {
    let nodeToFocus;
    let flattenedJson = json[0].children.map((child, index) => {
      let newChild = { node: child, listDepth: listDepth, toList: true };
      childDepthsToTransform.forEach((depth, i) => {
        if(depth === index) {
          child.tag = 'p';
          child.attribs['data-hash'] = hashids.encode(Math.floor(Math.random() * 9999 + 1));
          if(i === 0) { nodeToFocus = child; }
          newChild = { node: child, listDepth: listDepth, toList: false };
        }
      });
      return newChild;
    });

    let elements = flattenedJson.reduce((prev, curr, i) => {
      if(curr.toList && prev.length < 1) {
        prev.push( { node: this.createList({ children: [curr.node] }), listDepth: curr.listDepth } );
      } else if(curr.toList && prev[i-1] && prev[i-1].tag === 'ul') {
        prev[i-1].children.push(curr);
      } else if(curr.toList && prev[i-1] && prev[i-1].tag !== 'ul') {
        prev.push( { node: this.createList({ children: [curr.node] }), listDepth: curr.listDepth } );
      } else {
        prev.push(curr);
      }
      return prev;
    }, []);

    elements[0].node.attribs['data-hash'] = json[0].attribs['data-hash'];
    return { elements: elements, nodeToFocus: nodeToFocus };
  },
}