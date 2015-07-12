import React from 'react';
import _ from 'lodash';
import htmlparser from 'htmlparser';

const ContentEditable = React.createClass({

    getInitialState() {
      return {
        html: null
      };
    },

    shouldComponentUpdate(nextProps, nextState){
      return nextState.html !== this.getDOMNode().innerHTML;
    },

    componentWillMount() {
      if(this.props.html) {
        let html = this.toHTML(this.props.html);
        this.setState({
          html: html
        });
      }
    },

    htmlParserHandler(html) {
      function handler(html) {
        return _.map(html, function(item) {
          if(!item.children) {
            return {
              tag: item.data,
              text: '',
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
            text: textContent,
            children: handler(item.children)
          };
        });
      }
      return handler(html);
    },

    buildJSON(html) {
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
    },
    
    toHTML(collection) {
      let result = (function recurse(html, string) {
        html.forEach(function(item) {
          if(!item.children) {
            if(item.tag === 'br') {
              string += ('<' + item.tag + '/>');
            } else {
              string += ('<' + item.tag + '>' + item.text + '</' + item.tag + '>');
            }
          } else if(item.children) {
              string += recurse(item.children, ('<' + item.tag + '>' + item.text));
              if(item.tag !== 'br') {
                string += ('</' + item.tag + '>');
              }
            }
        });
        return string;
      }(collection, ''));
      
      return result;
    },

    emitChange(e){
      let html = React.findDOMNode(this).innerHTML;

      if (this.props.onChange) {
        this.buildJSON(html).then(function(json) {
          this.props.onChange({
            target: {
              value: json,
              json: json
            }
          });
        }.bind(this), function(err) {
          console.log(err);
        });
      }

      this.setState({
        html: html
      });
    },

    render(){

      return (
        <div key={this.props.refLink}
          ref={this.props.refLink}
          id="contenteditable"
          style={this.props.style} 
          onInput={this.emitChange} 
          onBlur={this.emitChange}
          contentEditable={true}
          dangerouslySetInnerHTML={{__html: this.state.html }}></div>
      );
    }
});

export default ContentEditable;