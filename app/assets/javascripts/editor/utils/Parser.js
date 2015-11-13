import Validator from 'validator';
import HtmlParser from 'htmlparser2';
import DomHandler from 'domhandler';
import _ from 'lodash';
import { BlockElements, ElementWhiteList } from './Constants';
import Hashids from 'hashids';
const hashids = new Hashids('hackster', 4);

export default {

  parseDOM(html, options) {
    options = Object.assign({}, { normalizeWhitespace: false }, options || {});
    return new Promise((resolve, reject) => {
      let handler = new DomHandler((err, dom) => {
        if(err) console.log('DomHandler Error: ', err);

        let parsed = this.parseTree(dom);
        // let cleaned = this.cleanTree(parsed);
        resolve(parsed);
      }, options);

      let parser = new HtmlParser.Parser(handler, { decodeEntities: true });
      parser.write(html);
      parser.done();
    }.bind(this));
  },

  parseTree(html) {
    const blockEls = BlockElements;

    function handler(html, depth) {

      if(!html.length) {
        return html;
      }

      return _.map(html, (item) => {
        /** Remove these nodes immediately. */
        if(item.name === 'script' || item.name === 'comment') {
          return null;
        } else if(item.name === 'br' && depth > 1) {
          return null;
        }

        /** Transform tags to whitelist. */
        item.name = this.transformTagNames(item);
        if(!ElementWhiteList[item.name]) {
          item.name = depth > 0 ? 'span' : 'p';
        }

        /** Remove invalid anchors. */
        if(item.name === 'a' && !Validator.isURL(item.attribs.href)) {
          return null;
        }

        if(item.type === 'text' && !item.children) {
          if(item.data.match(/&nbsp;/g)) {
            item.data = item.data.replace(/&nbsp;/g, ' ');
          }

          if(item.data && item.data.length === 1 && (item.data === '\n' || item.data === '\r')) {
            return null;
          } else {
            return {
              tag: 'span',
              content: item.data,
              attribs: {},
              children: []
            };
          }
        } else if(item.children && item.children.length === 1 && item.children[0].type === 'text') {
          if(item.children[0].data.match(/&nbsp;/g)) {
            item.children[0].data = item.children[0].data.replace(/&nbsp;/g, ' ');
          }
          return {
            tag: item.name,
            content: item.children[0].data,
            attribs: item.attribs,
            children: []
          };
        } else {
          return {
            tag: name || item.name,
            content: null,
            attribs: item.attribs,
            children: handler.apply(this, [item.children || [], depth+1])
          }
        }
      }).filter(item => { return item !== null; });
    }
    return handler.call(this, html, 0, null);
  },

  transformTagNames(node) {
    let nodeName = node.name;

    let converter = {
      'b': 'strong',
      'bold': 'strong',
      'italic': 'em',
      'i': 'em',
      'ol': 'ul',
      'h1': 'h3',
      'h2': 'h3',
      'h4': 'h3'
    };

    return converter[nodeName] || nodeName;
  },

  cleanTree(json) {
    console.log('clean', json);
    return json.map(item => {
      item.children = this.cleanBlockElementChildren(item.children);
      return item;
    });
  },

  cleanBlockElementChildren(node) {
    let children = node.children;
    const blockEls = BlockElements;

    children = (function recurse(children) {
      return children.map(child => {
        if(!child.children.length) {
          return child;
        } else {
          if(child.name && blockEls[child.name.toUpperCase()]) {
            child.name = 'span';
          }
          child.children = recurse(child.children);
          return child;
        }
      });
    }(children));

    return children
  },

  removeAttributes(json) {
    return (function recurse(json) {
      return json.map(child => {
        if(!child.children || !child.children.length) {
          if(child.tag !== 'a') {
            child.attribs = {};
          } else {
            child.attribs = { href: child.attribs.href };
          }
          return child;
        } else {
          if(child.tag !== 'a') {
            child.attribs = {};
          } else {
            child.attribs = { href: child.attribs.href };
          }
          child.children = recurse(child.children);
          return child;
        }
      });
    }(json));
  },

  concatPreBlocks(json) {
    let clone = _.clone(json);
    let indexesToConcat = this._getIndexesToConcat(clone);
    let map = indexesToConcat.map(indexes => {
      let merged = this._mergeBlocksByIndex(clone, indexes);
      return { ...indexes, pre: merged };
    });

    map.forEach(item => {
      let indexesToRemove = item.stop - item.start;
      json.splice(item.start, indexesToRemove+1, item.pre);
    });

    return json;
  },

  _getIndexesToConcat(json) {
    let indexesToConcat = [];
    let start = null, stop = null;

    json.forEach((item, index) => {
      if(item.tag === 'pre' && json[index+1] && json[index+1].tag === 'pre' && start === null) {
        start = index;
      } else if(item.tag === 'pre' && json[index+1] && json[index+1].tag !== 'pre' && start !== null) {
        stop = index;
        indexesToConcat.push({ start: start, stop: stop });
        start = null;
        stop = null;
      }
    });

    return indexesToConcat;
  },

  _mergeBlocksByIndex(json, indexes) {
    let merger = {},
        cont = false,
        children,
        code = { tag: 'code', attribs: {}, content: '', children: [] };

    json.forEach((item, index) => {
      if(index === indexes.start) {
        cont = true;
        if(item.children.length) {
          code.children.push(this._flattenChildren(item.children));
          merger = { tag: 'pre', attribs: {}, content: '', children: [ code ] };
        } else {
          code.children.push(this._createSpan(item.content));
          merger = { tag: 'pre', attribs: {}, content: '', children: [ code ] };
        }
      } else if(index === indexes.stop) {
        cont = false;
        if(item.children.length) {
          merger.children[0].children.push(this._flattenChildren(item.children));
        } else {
          merger.children[0].children.push(this._createSpan(item.content));
        }
      } else if(cont === true) {
        if(item.children.length) {
          merger.children[0].children.push(this._flattenChildren(item.children));
        } else {
          merger.children[0].children.push(this._createSpan(item.content));
        }
      }
    });

    return merger;
  },

  _createSpan(content) {
    return { tag: 'span', attribs: {}, content: content+'\n', children: [] };
  },

  _flattenChildren(children) {
    let content = [];

    (function recurse(array) {
      if(!array.length) {
        return;
      } else {
        array.forEach(item => {
          if(item.children.length) {
            recurse(item.children);
          } else {
            content.push(item.content);
          }
        });
      }
    }(children));

    return this._createSpan(content.join(''));
  },

  toHtml(json) {
    let attribs, tag, innards, children;
    return json.map(item => {
      attribs = this.getAttributesByTagType(item);
      tag = `<${item.tag}${attribs}>`;
      innards = item.content || '';
      children = item.children && item.children.length < 1 ? '' : this.toHtml(item.children);
      return item.tag === 'br' ? `<${item.tag}/>` : `${tag}${innards}${children}</${item.tag}>`;
    }).join('');
  },

  getAttributesByTagType(item) {
    let hash = item.attribs && item.attribs['data-hash'] ? item.attribs['data-hash'] : hashids.encode(Math.floor(Math.random() * 9999 + 1));
    let block = BlockElements[item.tag.toUpperCase()] ? item.tag : null;
    let classes = item.attribs.class || '';
    let attribs = {
      'a': ` href="${item.attribs.href}"`,
      [block]: ` data-hash="${hash}" class="${classes}"`
    };
    return attribs[item.tag] ? attribs[item.tag] : '';
  }
}