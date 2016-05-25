import HtmlParser from 'htmlparser2';
import DomHandler from 'domhandler';
import validator from 'validator';
import sanitizer from 'sanitizer';

export const BlockElements = {
  'P': true,
  'UL': true,
  'H3': true,
  'BLOCKQUOTE': true,
  'PRE': true
};

export const ElementWhiteList = {
  'p': true,
  'a': true,
  'pre': true,
  'blockquote': true,
  'ul': true,
  'h3': true,
  'code': true,
  'strong': true,
  'span': true,
  'br': true,
  'em': true,
  'li': true
};

function transformTagNames(node) {
  const converter = {
    'b': 'strong',
    'bold': 'strong',
    'italic': 'em',
    'i': 'em',
    'ol': 'ul',
    'h1': 'h3',
    'h2': 'h3',
    'h4': 'h3'
  };

  return converter[node.name] || node.name;
}

function createSpan(content) {
  return { tag: 'span', attribs: {}, content: content + '\n', children: [] };
}

function flattenChildren(children) {
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

  return content.length ? createSpan(content.join('')) : null;
}

function createPreChildren(node) {
  let children = [];

  if(node.children.length) {
    node = node.children[0].tag === 'code' ? node.children[0] : node;
    if(node.content) children.push(createSpan(node.content));
    children.push(flattenChildren(node.children));
  } else {
    children.push(createSpan(node.content));
  }

  return children.filter(child => child !== null);
}

function concatPreBlocks(json) {
  return json.reduce((acc, curr, index) => {
    if(acc.length > 0 && acc[acc.length-1].tag === 'pre' && curr.tag === 'pre') {
      let children = createPreChildren(curr);
      acc[acc.length-1].children[0].children.push(...children);
    } else {
      if(curr.tag === 'pre') {
        let code = { tag: 'code', attribs: {}, content: '', children: createPreChildren(curr) };
        acc.push({ tag: 'pre', attribs: {}, content: '', children: [ code ] });
      } else {
        acc.push(curr);
      }
    }
    return acc;
  }, []);
}

function getAttributesByTagType(item) {
  item.attribs = item.attribs || {};
  let block = BlockElements[item.tag.toUpperCase()] ? item.tag : null;
  let classes = item.attribs.class || '';
  let attribs = {
    'a': ` href="${item.attribs.href}"`,
    [block]: ` class="${classes}"`
  };
  return attribs[item.tag] ? attribs[item.tag] : '';
}

function parseTree(html) {
  const blockEls = BlockElements;

  function handler(html, depth) {
    if(!html.length) {
      return html;
    }

    return html.map(item => {
      /** Transform tags to whitelist. */
      item.name = transformTagNames(item);

      if(!ElementWhiteList[item.name]) {
        item.name = depth > 0 ? 'span' : 'p';
      }

      /** Remove invalid anchors. */
      if(item.name === 'a' && !validator.isURL(item.attribs.href)) {
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
            content: sanitizer.escape(item.data),
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
          content: sanitizer.escape(item.children[0].data),
          attribs: item.attribs,
          children: []
        };
      } else {
        return {
          tag: name || item.name,
          content: null,
          attribs: item.attribs,
          children: handler(item.children || [], depth+1)
        }
      }
    })
    .filter(item => item !== null);
  }
  return handler(html, 0);
}

export default function parseHTML(html, options) {
  options = options || {};

  return new Promise((resolve, reject) => {
    let handler = new DomHandler((err, dom) => {
      if(err) reject('DomHandler Error: ', err);

      const cleaned = parseTree(dom);
      const concated = concatPreBlocks(cleaned);
      resolve(concated);
    }, { ...options, normalizeWhitespace: false });

    let parser = new HtmlParser.Parser(handler, { decodeEntities: true });
    parser.write(html);
    parser.done();
  });
}