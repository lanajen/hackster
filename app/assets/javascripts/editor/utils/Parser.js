import Validator from 'validator';
import HtmlParser from 'htmlparser2';
import DomHandler from 'domhandler';
import _ from 'lodash';
import { BlockElements, ElementWhiteList } from './Constants';
import { treeWalk } from './Traversal';
import Hashids from 'hashids';
const hashids = new Hashids('hackster', 4);

export default {

  parseDOM(html, options) {
    options = Object.assign({}, { normalizeWhitespace: false }, options || {});
    return new Promise((resolve, reject) => {
      let handler = new DomHandler((err, dom) => {
        if(err) console.log('DomHandler Error: ', err);

        let parsed = this.parseTree(dom);
        let cleaned = this.cleanTree(parsed);
        resolve(cleaned);
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
    return json.map(item => {
      item.children = this.cleanBlockElementChildren(item.children);
      return item;
    });
  },

  cleanBlockElementChildren(children) {
    let newChildren = children.map(child => {
      if(children.length > 1 && child.tag === 'br') {
        return null;
      } else {
        return child;
      }
    }).filter(item => item !== null);

    return newChildren;
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
    json = json.reduce((prev, curr, index) => {
      if(prev.length > 0 && prev[prev.length-1].tag === 'pre' && curr.tag === 'pre') {
        let children = this._createPreChildren(curr);
        prev[prev.length-1].children[0].children.push(...children);
      } else {
        if(curr.tag === 'pre') {
          let code = { tag: 'code', attribs: {}, content: '', children: this._createPreChildren(curr) };
          prev.push({ tag: 'pre', attribs: {}, content: '', children: [ code ] });
        } else {
          prev.push(curr);
        }
      }
      return prev;
    }, []);
    return json;
  },

  _createPreChildren(node) {
    let children = [];

    if(node.children.length) {
      node = node.children[0].tag === 'code' ? node.children[0] : node;
      if(node.content) { children.push(this._createSpan(node.content)); }
      children.push(this._flattenChildren(node.children));
    } else {
      children.push(this._createSpan(node.content));
    }

    return children;
  },

  postCleanUp(json) {
    return json.map((child, index) => {
      if(child.content === 'Paste a link to Youtube, Vimeo or Vine and press Enter') {
        return null;
      } else {
        if(child.children.length) {
          child.children = this.postCleanUp(child.children);
          return child;
        } else {
          return child;
        }
      }
    }).filter(item => item !== null);
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
    item.attribs = item.attribs || {};
    let hash = item.attribs['data-hash'] || hashids.encode(Math.floor(Math.random() * 9999 + 1));
    let block = BlockElements[item.tag.toUpperCase()] ? item.tag : null;
    let classes = item.attribs.class || '';
    let attribs = {
      'a': ` href="${item.attribs.href}"`,
      [block]: ` data-hash="${hash}" class="${classes}"`
    };
    return attribs[item.tag] ? attribs[item.tag] : '';
  },

  stringifyLineBreaksToParagraphs(text, nodeName) {
    let lines = text.split('\n');
    let tag = nodeName === 'PRE' ? 'pre' : 'p';
    return lines.map(line => {
      line = !line.length ? '<br/>' : line;
      return `<${tag} data-hash="${hashids.encode(Math.floor(Math.random() * 9999 + 1))}">${line}</${tag}>`;
    }).join('');
  },
}