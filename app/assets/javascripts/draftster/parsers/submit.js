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

function removeAttributes(json) {
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

function createSpan(content) {
  return { tag: 'span', attribs: {}, content: content+'\n', children: [] };
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

  return createSpan(content.join(''));
}

function createPreChildren(node) {
  let children = [];

  if(node.children.length) {
    node = node.children[0].tag === 'code' ? node.children[0] : node;
    if(node.content) { children.push(createSpan(node.content)); }
    children.push(flattenChildren(node.children));
  } else {
    children.push(createSpan(node.content));
  }

  return children;
}

function concatPreBlocks(json) {
  json = json.reduce((prev, curr, index) => {
    if(prev.length > 0 && prev[prev.length-1].tag === 'pre' && curr.tag === 'pre') {
      let children = createPreChildren(curr);
      prev[prev.length-1].children[0].children.push(...children);
    } else {
      if(curr.tag === 'pre') {
        let code = { tag: 'code', attribs: {}, content: '', children: createPreChildren(curr) };
        prev.push({ tag: 'pre', attribs: {}, content: '', children: [ code ] });
      } else {
        prev.push(curr);
      }
    }
    return prev;
  }, []);
  return json;
}

function postCleanUp(json) {
  return json.map((child, index) => {
    if(child.content === 'Paste a link to Youtube, Vimeo or Vine and press Enter') {
      return null;
    } else {
      if(child.children.length) {
        child.children = postCleanUp(child.children);
        return child;
      } else {
        return child;
      }
    }
  })
  .filter(item => item !== null);
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

parseTree(html) {
  const blockEls = BlockElements;

  function handler(html, depth) {
    if(!html.length) {
      return html;
    }

    return html.map(item => {
      /** Remove these nodes immediately. */
      if(item.name === 'script' || item.name === 'comment') {
        return null;
      } else if(item.name === 'br' && depth > 1) {
        return null;
      }

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
            content:sanitizerescape(item.data),
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
          content:sanitizerescape(item.children[0].data),
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

      let cleaned = parseTree(dom);
      cleaned = removeAttributes(cleaned);
      cleaned = concatPreBlocks(cleaned);
      cleaned = postCleanUp(cleaned);
      resolve(cleaned);
    }, { ...options, normalizeWhitespace: false });

    let parser = new HtmlParser.Parser(handler, { decodeEntities: true });
    parser.write(html);
    parser.done();
  });
}