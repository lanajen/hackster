import Validator from 'validator';
import HtmlParser from 'htmlparser2';
import DomHandler from 'domhandler';
import _ from 'lodash';

export default {

  parseDOM(html) {
    return new Promise((resolve, reject) => {
      let handler = new DomHandler((err, dom) => {
        if(err) console.log(err);

        let parsedHTML = this.parseTree(dom);
        resolve(parsedHTML);

      }, { normalizeWhitespace: false });

      let parser = new HtmlParser.Parser(handler, { decodeEntities: true });
      parser.write(html);
      parser.done();
    }.bind(this));
  },

  parseTree(html) {
    const blockEls = {
      p: true,
      blockquote: true,
      ul: true,
      pre: true
    };

    function handler(html) {
      return _.map(html, (item) => {
        let name;

        /** Remove these nodes immediately. */
        if(item.name === 'br' || item.name === 'script' || item.name === 'comment') {
          return null;
        }
        /** Transform tags to whitelist. */
        if(item.name) {
          name = this.transformTagNames(item);
        }

        /** Remove invalid anchors. */
        if(item.name === 'a' && !Validator.isURL(item.attribs.href)) {
          return null;
        }

        /** Recurse through block elements and make sure only inlines exist as children. */
        if(blockEls[item.name]) {
          item.children = this.cleanBlockElementChildren(item);
        }

        if(item.type === 'text' && !item.children) {
          if(item.data.match(/&nbsp;/g)) {
            item.data = item.data.replace(/&nbsp;/g, ' ');
          }

          return {
            tag: 'span',
            content: item.data,
            attribs: {},
            children: []
          };
        } else if(item.children && item.children.length === 1 && item.children[0].type === 'text') {
          if(item.children[0].data.match(/&nbsp;/g)) {
            item.children[0].data = item.children[0].data.replace(/&nbsp;/g, ' ');
          }
          return {
            tag: name || item.name,
            content: item.children[0].data,
            attribs: item.attribs,
            children: []
          };
        } else {
          return {
            tag: name || item.name,
            content: null,
            attribs: item.attribs,
            children: handler.apply(this, [item.children || []])
          }
        }
      }).filter(item => { return item !== null; });
    }
    return handler.call(this, html);
  },

  transformTagNames(node) {
    let nodeName = node.name;

    let converter = {
      'b': 'strong',
      'bold': 'strong',
      'italic': 'em',
      'i': 'em',
      'ol': 'ul'
    };

    return converter[nodeName] || nodeName;
  },

  cleanBlockElementChildren(node) {
    let children = node.children;
    const blockEls = {
      p: true,
      blockquote: true,
      ul: true,
      pre: true
    };

    children = (function recurse(children) {
      return children.map(child => {
        if(!child.children || !child.children.length) {
          return child;
        } else {
          if(child.name && blockEls[child.name]) {
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
  }
}