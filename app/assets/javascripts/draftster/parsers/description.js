/**
 * This parser is to turn an html string into Hackster's json model.  (i.e. project[:story_json])
 * It's pretty expensive to run and meant only for an initial parse.
 * However, if speed is not an issue, use this as a strict html parser.
 */

import HtmlParser from 'htmlparser2';
import DomHandler from 'domhandler';
import sanitizer from 'sanitizer';
import validator from 'validator';

import Helpers from '../../utils/Helpers';

const BlockElements = {
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

function recurseElement(element) {
  let mediaType = false;
  const blockEls = {
    'div': true,
    'p': true,
    'ul': true,
    'blockquote': true,
    'pre': true,
    'h3': true
  };
  let el = (function recurse(el, depth) {
    let child;

    if(!el.children) {
      return el;
    }

    for(let i = el.children.length; i > 0; i--) {
      child = el.children[i-1];

      /** Remove script tags */
      if(child.type === 'script' || child.name === 'script') {
        child.parent.children.splice(i-1, 1);
      }

      /** Flag an image */
      if(child.name === 'img') {
        mediaType = 'image';
      }

      /** Force unlinked anchors to ems. */
      if(child.name === 'a' && !validator.isURL(child.attribs.href)) {
        child.name = 'em';
      }
      /** If child has no name, its likely a text node or comment.  Force these to spans and add an attribs object. */
      if(child.name === undefined) {
        child.name = 'span';
        child.attribs = child.attribs || {};
      }

      /** Transform any nested block element to a span, maintain top level element as a block. */
      if(blockEls[child.name] && depth !== 0) {
        child.name = 'span';
      } else if(child.name === 'div' && depth === 0) {
        child.name = 'p';
      }

      if(child.children && child.children.length > 0) {
        /** Recursion */
        recurse(child, depth+1);
        if(child.children.length < 1) {
          child.parent.children.splice(i-1, 1);
        }
      } else {
        if(!child.data && child.name !== 'img' && (child.attribs['data-type'] && child.attribs['data-type'] !== 'url')) {
          // Node has no content.
          child.parent.children.splice(i-1, 1);
        }
      }
    }
    return el;
  }(element, 0));

  return {
    mediaType: mediaType,
    el: el
  };
}

function recurseAndReturnEl(parentEl, elName) {
  var el;

  (function recurse(parentEl) {
    if(!parentEl.children) {
      return parentEl;
    } else {
      parentEl.children.forEach(child => {
        if(child.name === elName) {
          el = child;
          return;
        }
        recurse(child);
      });
    }
  }(parentEl));

  return el;
}

function findImageWrapper(element) {
  let imgWrapper;

  (function recurse(el){
    if(!el.children) {
      return el;
    } else {
      el.children.forEach(child => {
        if(child.name === 'div' && child.attribs.class && child.attribs.class.indexOf('react-editor-image-wrapper') !== -1) {
          imgWrapper = child;
        }
        recurse(child);
      });
    }
  } (element));

  return imgWrapper;
}

function getURLWidgetData(element) {
  let src, figcaption, type, widgetType;

  (function recurse(el) {
    if(!el.children) {
      return el;
    } else {
      /** Get the url from the root element. */
      if(el.attribs.class && el.attribs.class.indexOf('embed-frame') !== -1 && el.attribs['data-type'] === 'url') {
        src = el.attribs['data-url'];
        type = 'iframe';
      }

      el.children.forEach(child => {
        /** Sets type to image. */
        if(child.attribs && child.attribs.class && child.attribs.class.indexOf('embed-img') !== -1) {
          type = 'image';
        }

        /** Get the video url from the iframe attribute rather than the embed url. */
        if(child.name === 'iframe' && child.attribs.src) {
          src = child.attribs.src;
        }

        /** Gets code repo url widgets */
        if(child.attribs && child.attribs['data-repo']) {
          type = 'repo';
          widgetType = child.attribs.class;
        }

        /** Grabs video figcaptions. */
        if(child.name === 'div' && child.attribs.class && child.attribs.class.indexOf('embed-figcaption') !== -1) {
          figcaption = child.children.length ? child.children[0].data : '';
        }

        recurse(child);
      });
    }

  }(element));

  return [{
    embed: src,
    figcaption: figcaption || '',
    type: type || '',
    widgetType: widgetType || ''
  }];
}

function getCarouselData(element) {
  let images = [];
  let carouselData = [];

  (function recurse(el) {
    if(!el.children) {
      return el;
    } else {
      el.children.forEach(child => {
        if(child.name === 'div' && child.attribs && child.attribs.class
           && child.attribs.class.indexOf('image') !== -1 && child.attribs['data-file-id']) {
          images.push(child);
        }
        recurse(child);
      });
    }
  }(element));

  images.forEach(image => {
    let obj = {};
    obj.id = image.attribs['data-file-id'] || null;

    (function recurse(i) {
      if(!i.children) {
        return i;
      } else {
        i.children.forEach(child => {
          if(child.name === 'img') {
            obj.url = child.attribs.src;
            obj.alt = child.attribs.alt;
            obj.show = false;
          }

          if(child.name === 'figcaption') {
            obj.figcaption = child.attribs['data-value'] || '';
          }
          recurse(child);
        });
      }
    }(image));

    carouselData.push(obj);
  });

  return carouselData;
}

function getImages(element) {
  let images = [];

  (function recurse(el) {
    let obj = {};
    if(!el.children) {
      return el;
    } else {
      el.children.forEach(child => {
        if(child.name === 'img') {
          /** If the embed image widget is nested in another element, get the id from the third parent up. */
          if(child.parent && child.parent.parent && child.parent.parent.parent && child.parent.parent.parent.attribs['data-file-id']) {
            obj.id = child.parent.parent.parent.attribs['data-file-id'];
          }
          obj.url = child.attribs.src;
          obj.alt = child.attribs.alt || '';
          obj.figcaption = '';
          obj.show = false;
          images.push(obj);
        }
        recurse(child);
      });
    }
  }(element));

  return images;
}

function getFileData(element) {
  let url,
      content,
      id = element.attribs['data-file-id'],
      caption = element.attribs['data-caption'] || '';

  (function recurse(el) {
    if(!el.children) {
      return el;
    } else {
      el.children.forEach(child => {
        if(child.name === 'a') {
          url = child.attribs.href;
          content = child.children[0].data
        }
        recurse(child);
      });
    }
  }(element));

  return { caption, content, id, url };
}

function getVideoData(element) {
  let src, figcaption;

  (function recurse(el) {
    if(!el.children) {
      return el;
    } else {
      /** Get the url from the root element. */
      if(el.attribs.class && el.attribs.class.indexOf('embed-frame') !== -1 && el.attribs['data-type'] === 'url') {
        src = el.attribs['data-url'];
      }

      el.children.forEach(child => {
        /** Get the video src from the source tag if it wasn't supplied in the parent. */
        if(src === undefined && child.name === 'source') {
          src = child.attribs['src'];
        }

        /** Grabs video figcaptions. */
        if(child.name === 'div' && child.attribs.class && child.attribs.class.indexOf('embed-figcaption') !== -1) {
          figcaption = child.children.length ? child.children[0].data : '';
        }

        recurse(child);
      });
    }

  }(element));

  return [{
    embed: src,
    figcaption: figcaption || '',
    service: 'mp4',
    type: ''
  }]
}

function getWidgetPlaceholderData(el) {
  let id, widgetType;

  id = el.attribs['data-widget-id'];
  widgetType = el.children[0].attribs.class.split(' ').pop();

  return {
    id: id,
    type: 'widget',
    widgetType: widgetType
  };
}

function createCarousel(images) {
  if(!images.length) { return null; }

  images[0].show = true;
  return {
    type: 'Carousel',
    images: images
  };
}

function createVideo(video) {
  return {
    type: 'Video',
    video: video
  };
}

function createFile(data) {
  return {
    type: 'File',
    data: data
  }
}

function createCodeBlock(data) {
  let pre = recurseAndReturnEl(data, 'pre');
  let PRE = {
    ...pre,
    children: [{
      name: 'code',
      children: pre.children,
      attribs: {},
      type: 'tag'
    }]
  };
  return {
    type: 'CE',
    json: [PRE]
  };
}

function createWidgetPlaceholder(data) {
  return {
    type: 'WidgetPlaceholder',
    data: data
  }
}

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

function cleanUL(ul) {
  let newChildren = (function recurse(children) {
    if(!children.length) {
      return children;
    } else {
      return children.map(child => {
        if(!child.children.length && (!child.content || child.content.match(/^[\u21B5|\s+]{1}$/) !== null)) {
          return null;
        } else {
          child.children = recurse(child.children);

          if(!child.children.length && (!child.content || child.content.match(/^[\u21B5|\s+]{1}$/) !== null)) {
            child = null;
          }

          return child;
        }
      }).filter(child => { return child !== null; });
    }
  }(ul.children));

  ul.children = newChildren;
  return ul;
}

function shallowlyCleanHeaderChildren(children) {
  const inlineMap = {
    bold: true,
    italic: true,
    a: true
  };
  return children.map(child => {
    if(inlineMap[child.tag]) {
      child.tag = 'span';
    }
    return child;
  });
}

function expandPreBlocks(json) {
  return json.reduce((acc, item) => {
    if(item.tag === 'pre') {
      // Create stacking pre blocks for text content
      if(item.content && item.content.length && item.content.match(/[\n\r]/g)) {
        acc = acc.concat(createPreBlocksByText(item.content));
      }
      // Create stacking pre blocks for childrens content.
      if(item.children && item.children.length) {
        item.children.forEach(child => {
          if(child.content && child.content.length) {
            acc = acc.concat(createPreBlocksByText(child.content));
          }
          // Spans.
          if(child.children && child.children.length) {
            child.children.forEach(c => {
              if(c.content && c.content.length) {
                acc = acc.concat(createPreBlocksByText(c.content));
              }
            });
          }
        });
      }
    } else {
      acc.push(item);
    }
    return acc;
  }, []);
}

function createPreBlocksByText(text) {
  const updatedText = text.replace(/[\n\r]/g, '/n');
  const blocks = updatedText.split('/n');

  return blocks.map(block => {
    return {
      tag: 'pre',
      content: '',
      attribs: {},
      children: [{
        tag: 'code',
        content: block,
        attribs: {},
        children: []
      }]
    };
  });
}

function createContainers(html) {
  let tree = html.map((el, index) => {
    let mediaData, carousel, video, newEl;
    /** If top element is a carousel widget or video, we create the markup for those elements.
      * Else if the top element is a image, create a Carousel.
      * Else, recurse through the element.
      *     If theres images in the element, we're going to convert it to a Carousel.
      *     Else return the processed tree.
     */
    if(el.name === 'div' && el.attribs.class && el.attribs.class.indexOf('embed-frame') !== -1) {
      if(el.attribs['data-type'] === 'widget' && el.children && el.children[0].attribs.class.indexOf('image_widget') !== -1) {
        /** Handle Carousel */
        mediaData = getCarouselData(el);
        newEl = createCarousel(mediaData);
        return newEl;
      } else if(el.attribs['data-type'] === 'video') {
        /** Primarily for mp4. */
        mediaData = getVideoData(el);
        newEl = createVideo(mediaData);
        return newEl;
      } else if(el.attribs['data-type'] === 'url') {
        /** Handle Video, Image & Repo as URL Widgets. */
        mediaData = getURLWidgetData(el);

        /** Repo gets transformed into a placeholder. */
        if(mediaData[0].type === 'repo') {
          newEl = createWidgetPlaceholder(mediaData[0]);
        } else {
          newEl = createVideo(mediaData);
        }

        return newEl;
      } else if(el.attribs['data-type'] === 'file') {
        /** Handle File */
        mediaData = getFileData(el);
        /** If file has no id or url, remove it. */
        if(!mediaData.url || !mediaData.id) {
          newEl = null;
        } else {
          newEl = createFile(mediaData);
        }
        return newEl;
      } else if(el.attribs['data-type'] === 'widget') {
        if(el.children && el.children[0].attribs.class.indexOf('old_code_widget') !== -1) {
          /** Handle Old Code Widget */
          mediaData = getWidgetPlaceholderData(el);
          newEl = createWidgetPlaceholder(mediaData);
        } else if(el.children && el.children[0].attribs.class.indexOf('parts_widget') !== -1) {
          mediaData = getWidgetPlaceholderData(el);
          newEl = createWidgetPlaceholder(mediaData);
        }
        return newEl;
      } else {
        return null;
      }
    } else if(el.name === 'img') {
      /** Handle Carousel */
      mediaData = [{ url: el.attribs.src, alt: el.attribs.alt || '' }];
      newEl = createCarousel(mediaData);
      return newEl;
    } else {
      let data = recurseElement(el);
      if(data.mediaType) {
        /** Handle Carousel */
        mediaData = getImages(data.el);
        newEl = createCarousel(mediaData);
        return [newEl, { type: 'CE', json: [data.el] }];
      } else {
        return {
          type: 'CE',
          json: [data.el]
        };
      }
    }
  }).
  filter(item => {
    return item !== null;
  }).
  reduce((acc, curr) => {
    if(Array.isArray(curr)) {
      acc = acc.concat(curr);
    } else {
      acc.push(curr);
    }
    return acc;
  }, []);

  return tree;
}

function parseTree(html) {
  function handler(html, depth) {
    return _.map(html, (item) => {
      let name;

      /** Remove these nodes immediately. */
      if(item.name === 'script' || item.name === 'comment' || item.name === 'meta') {
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

      /** Removes styles. */
      if(item.attribs && item.attribs.style) {
        item.attribs.style = '';
      }
      /** Removes classes. */
      if (item.attribs && item.attribs.class) {
        item.attribs.class = '';
      }

      if(item.type === 'text' && !item.children) {
        if(item.data.match(/&nbsp;/g)) {
          item.data = item.data.replace(/&nbsp;/g, ' ');
        }

        return {
          tag: 'span',
          content: sanitizer.escape(item.data),
          attribs: {},
          children: []
        };
      } else if(item.children && item.children.length === 1 && item.children[0].type === 'text') {
        if(item.children[0].data.match(/&nbsp;/g)) {
          item.children[0].data = item.children[0].data.replace(/&nbsp;/g, ' ');
        }
        return {
          tag: name || item.name,
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
    }).filter(item => { return item !== null; });
  }
  return handler(html, 0);
}

function cleanTree(json) {
  return json.map(item => {
    if(item.tag === 'li') {
      item.tag = 'ul';
      item.children = [{
        tag: 'li',
        content: item.content,
        attribs: {},
        children: []
      }];
      item.content = null;

      /** Removes empty li's nested or not */
      item = cleanUL(item);

      /** We do this last because cleanUL will dive in recursively and remove all empty tags including the li we just added. */
      if(!item.content || !item.children.length) {
        item = null;
      }

      return item;
    } else if(item.tag === 'ul') {
      if(!item.children.length && item.content && item.content.length > 0) {
        item.children.push({
          tag: 'li',
          attribs: {},
          children: [],
          content: item.content
        });
        item.content = '';
      }

      item.children = item.children.map(child => {
        if(child.children && !child.children.length && child.content && child.content.length <= 1 && (child.content === '\n' || child.content === ' ')) {
          return null;
        } else if(child.tag !== 'li') {
          child.tag = 'li';
          return child
        } else {
          return child;
        }
      }).filter(child => { return child !== null; });

      /** Removes empty li's nested or not */
      item = cleanUL(item);
      return item;
    } else if(item.tag === 'div') {
      item.tag = 'p';

      if(item.children.length < 1) {
        item.children.push({
          tag: 'br',
          content: '',
          attribs: {},
          children: []
        });
      }

      return item;
    } else if(item.tag === 'h3') {
      item.children = shallowlyCleanHeaderChildren(item.children);
      return item;
    } else if(item.tag === 'span') {
      if(item.content && item.content === '\n' || item.content === ' ') {
        return null;
      } else {
        item.tag = 'p';

        if(item.children.length < 1) {
          item.children.push({
            tag: 'br',
            content: '',
            attribs: {},
            children: []
          });
        }

        return item;
      }
    } else if(item.tag === 'br') {
      return null;
    } else if(!BlockElements[item.tag.toUpperCase()]) {
      /** Catches other inlines and wraps the item in a parapraph. */
      let p = {
        tag: 'p',
        content: '',
        attribs: {},
        children: [ item ]
      };
      return p;
    } else if(item.tag === 'p' && item.children && item.children.length < 1) {
      /** Remove any carriage returns and get rid of the element if it's then empty. */
      if(item.content && item.content.match(/\n/)) {
        item.content = item.content.replace(/\n/g, '');
      }
      if(item.content && !item.content.length) {
        item = null;
      }
      if(item.content === null && !item.children.length) {
        item = null;
      }
      return item;
    } else if( (item.children === null || !item.children.length) && (item.content === null || !item.content.length) ) {
      return null;
    } else {
      return item;
    }
  }).filter(c => { return c !== null; });
}

function mergeAndParseTree(collection, options) {
  let newCollection = [];

  collection.forEach((component, index) => {
    if(index > 0 && collection[index-1].type === 'CE' && component.type === 'CE') {
      newCollection[newCollection.length-1].json.push(...component.json);
    } else if(component.type === 'Video' && component.video[0].type === 'iframe') {
      const videoData = Helpers.getVideoData(component.video[0].embed);

      component.video[0] = { ...component.video[0], ...videoData };
      newCollection.push(component);
    } else {
      newCollection.push(component);
    }
  });

  newCollection = newCollection.map(coll => {
    if(coll.type === 'CE') {
      coll.json = parseTree(coll.json);
      coll.json = cleanTree(coll.json);

      // Unfold pre's on initial description parse.
      if(options && options.initialParse) {
        coll.json = expandPreBlocks(coll.json);
      }
      return coll;
    } else {
      return coll;
    }
  })
  .filter(coll => {
    return coll.type === 'CE' && !coll.json.length ? false : true;
  });

  /** Makes sure theres always a CE at the end. */
  if(newCollection[newCollection.length-1] && newCollection[newCollection.length-1].type !== 'CE') {
    newCollection.push({
      type: 'CE',
      json: [{
        tag: 'p',
        attribs: {},
        children: [],
        content: null
      }]
    });
  }

  return newCollection;
}

function parseDescription(html, options) {
  return new Promise((resolve, reject) => {
    let handler = new DomHandler((err, dom) => {
      if(err) reject(err);

      const containerd = createContainers(dom);
      const parsedHtml = mergeAndParseTree(containerd, options);

      resolve(parsedHtml);
    }, {});

    let parser = new HtmlParser.Parser(handler, { decodeEntities: true });
    parser.write(html);
    parser.done();
  });
}

export { expandPreBlocks, parseDescription };
