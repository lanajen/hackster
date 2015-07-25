import { Editor } from '../constants/ActionTypes';
import _ from 'lodash';
import htmlparser from 'htmlparser';

const initialState = {
  html: '<p>Start</p>',
  dom: [
    {tag: 'p',
     content: 'First Parent',
     indexPos: [0, 0],
     children: [{
      tag: 'a',
      content: 'anchor',
      indexPos: [1, 0],
      children: []
     }]
    },
    {
      tag: 'p',
      content: 'Second P',
      indexPos: [0, 1],
      children: []
    }
  ]
};

export default function(state = initialState, action) {
  switch (action.type) {
    case Editor.setHTML:
      return {
        ...state,
        html: action.html
      };

    case Editor.setSelectedText:
      return {
        ...state,
        selectedText: action.data
      };

    case Editor.isTextSelected:
      return {
        ...state,
        isTextSelected: action.bool
      };

    case Editor.addMarkup:
      return {
        ...state
      };

    default:
      return state;
  };
}

function htmlParserHandler(html) {
  function handler(html) {
    return _.map(html, function(item) {
      if(!item.children) {
        return {
          tag: item.data,
          content: '',
          children: []
        };
      }
      
      let textContent;
      if(item.children) {
        textContent = item.children.shift();
        textContent = textContent.data;
      }
      return {
        tag: item.data,
        content: textContent,
        children: handler(item.children)
      };
    });
  }
  return handler(html);
}

function buildJSON(html) {
  return new Promise((resolve, reject) => {
    let handler = new htmlparser.DefaultHandler(function(err, dom) {
      if(err) { reject(err) }

      else {
        resolve(this.htmlParserHandler(dom));
      }
    }.bind(this));

    let parser = new htmlparser.Parser(handler);
    parser.parseComplete(html);
  }.bind(this));
}
    
function toHTML(collection) {
  let result = (function recurse(html, string) {
    html.forEach(function(item) {
      if(!item.children) {
        if(item.tag === 'br') {
          string += ('<' + item.tag + '/>');
        } else {
          string += ('<' + item.tag + '>' + item.content + '</' + item.tag + '>');
        }
      } else if(item.children) {
          string += recurse(item.children, ('<' + item.tag + '>' + item.content));
          if(item.tag !== 'br') {
            string += ('</' + item.tag + '>');
          }
        }
    });
    return string;
  }(collection, ''));
  
  return result;
}

