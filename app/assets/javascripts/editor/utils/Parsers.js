import HtmlParser from 'htmlparser2';
import DomHandler from 'domhandler';
import _ from 'lodash';

export default {

  parseDOM(html, callback) {
    let handler = new DomHandler((err, dom) => {
      if(err) { reject(err); }
      
      let parsedHTML = this.parseTree(dom);
      callback(parsedHTML);
    });

    let parser = new HtmlParser.Parser(handler, { decodeEntities: true });
    parser.write(html);
    parser.done();
  },

  parseTree(html) {
    function handler(html) {
      return _.map(html, function(item) {
        let name;
        if(item.name) {
          name = this.transformTagNames(item);
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
      }.bind(this));
    }
    return handler.call(this, html);
  },

  transformTagNames(node) {
    let nodeName = node.name;

    if(node.name === 'div' && node.attribs['data-type']) {
      nodeName = node.attribs['data-type'];
    }

    let converter = {
      'b': 'strong',
      'i': 'em',
      'carousel': 'carousel',
      'video': 'video'
    };

    return converter[nodeName] || nodeName;
  }

};