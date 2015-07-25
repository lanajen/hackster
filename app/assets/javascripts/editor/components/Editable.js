import React from 'react';
import _ from 'lodash';
import ContentEditable from '../../reusable_components/ContentEditable';
import { createRandomNumber } from '../../utils/Helpers';
import Paragraph from './Paragraph';
import Anchor from './Anchor';

const Editable = React.createClass({

  onEnterKey() {
    // UPDATE DOM STORE!!!
  },

  render() {
    var template = toHTML(this.props.editor.dom);
    // Recurse through JSON and create react elements.
    let content = _.map(this.props.editor.dom, function(el, index) {
      // IF NO CHILDREN, RETURN;
      // MAP TO el.tag A CALLBACK RETURNING JSX COMPONENT MARKUP.
      // IF CHILDREN RECURSE.
      let children = [];

      if(el.children.length > 0) {
        children = _.map(el.children, function(item, index) {
          if(item.tag === 'a') {
            return <Anchor key={index} href="www.google.com" content={item.content} indexPos={item.indexPos} />
          }
        }); 
      }

      return <Paragraph key={index} ref={this.props.refLink} refLink={createRandomNumber()} content={el.content} indexPos={el.indexPos} editable={el.editable || false} onEnterKey={this.onEnterKey}>{children}</Paragraph>;
    }.bind(this));

    console.log(content[0].props.children[0].props);

    return (
      <div className="box-content" onMouseUp={this.onSelection} >
        {content}
      </div>
    );
  }

});

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

export default Editable;