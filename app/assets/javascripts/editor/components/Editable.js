import React from 'react/addons';
import _ from 'lodash';
import async from 'async';
import DropZone from '../../reusable_components/DropZone';
import ContentEditable from './ContentEditable';
import ImageToolbar from './ImageToolbar';
import { createRandomNumber } from '../../utils/Helpers';
import Utils from '../../utils/DOMUtils';
import ImageUtils from '../../utils/Images';
import Validator from 'validator';
import HtmlParser from 'htmlparser2';
import DomHandler from 'domhandler';

const Editable = React.createClass({

  componentWillMount() {
    this.props.actions.fetchInitialDOM();
  },

  shouldComponentUpdate(nextProps) {
    return nextProps.editor.dom !== this.props.editor.dom ||
           nextProps.isEditable !== this.props.editor.isEditable;
  },

  handleContentEditableChange(html) {
    let promise = this.parseDOM(html);
    promise.then(function(dom) {
      this.props.actions.setDOM(dom);
    }.bind(this)).catch(function(err) { console.log('Parse Error: ' + err); });
  },

  parseDOM(html) {
    return new Promise((resolve, reject) => {
      let handler = new DomHandler(function(err, dom) {
        if(err) console.log(err);
        
        let parsedHTML = this.parseTree(dom);
        this.convertImageSrc(parsedHTML, function(newHTML) {
          resolve(newHTML);
        });
      }.bind(this), {});

      let parser = new HtmlParser.Parser(handler, { decodeEntities: true });
      parser.write(html);
      parser.done();
    }.bind(this));
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
  },

  convertImageSrc(html, mainCallback) {
    async.map(html, function(item, callback) {
      if(item.tag === 'figure') {
        _.forEach(item.children, function(child) {
          if(child.tag === 'img' && child.attribs['data-src'] && child.attribs['data-src'].length > 0) {
            if(Validator.isURL(child.attribs['data-src'])) {
              let promise = ImageUtils.createDataURLFromURL(child.attribs['data-src']);
              promise.then(function(dataUrl) {
                child.attribs = Object.assign(child.attribs, { src: dataUrl });
              });
            }
          }
        });
      }
      callback(null, item);
    }, function(err, result) {
      mainCallback(result);
    });
  },

  // handleEditableMouseEnter(e) {
  //   e.preventDefault();
  //   e.stopPropagation();
  //   if(!this.props.editor.isHovered) {
  //     this.props.actions.isHovered(true);
  //   }
  // },

  // handleEditableMouseLeave(e) {
  //   e.preventDefault();
  //   e.stopPropagation();
  //   if(this.props.editor.isHovered) {
  //     setTimeout(function() {
  //       this.props.actions.isHovered(false);
  //     }.bind(this), 500);
  //   }
  // },

  handleFilesDrop(files) {
    let node = Utils.getRootParentElement(this.props.editor.cursorPosition.node);
    let depth = Utils.findChildsDepthLevel(node, node.parentNode);
    
    ImageUtils.handleImagesAsync(files, function(map) {
      this.props.actions.createCarousel(map, depth);
      this.props.actions.forceUpdate(true);
    }.bind(this));
  },

  handleMouseOut(e) {
    e.preventDefault();
    e.stopPropagation();
    let node = React.findDOMNode(e.target);

    /** 
     * Handles releasing the ImageToolbar overlay component.
     * First we handle an edge case where the mouse was in a button then placed outside the CE. 
     * Secondly we handle ignoring any elements inside the Carousel.
    **/
    if(node.nodeName === 'BUTTON' && e.nativeEvent.relatedTarget 
       && (e.nativeEvent.relatedTarget.classList.contains('react-editor-image-wrapper') || e.nativeEvent.relatedTarget.classList.contains('row'))
       && this.props.editor.showImageToolbar === true) {
      this.props.actions.toggleImageToolbar(false, {});
    } else if(node.nodeName === 'DIV' && node.classList.contains('react-editor-image-overlay') 
       && (e.nativeEvent.relatedTarget && !e.nativeEvent.relatedTarget.classList.contains('reit-controls'))
       && (e.nativeEvent.relatedTarget && e.nativeEvent.relatedTarget.nodeName !== 'BUTTON')
       && (e.nativeEvent.relatedTarget && !Utils.getRootOverlayElement(e.nativeEvent.relatedTarget).classList.contains('reit-toolbar'))
       && this.props.editor.showImageToolbar === true) {
      this.props.actions.toggleImageToolbar(false, {});
    }
  },

  render() {
    let dom = this.props.editor.dom;
    let html = dom.length < 1 ? this.props.editor.html : dom.map(React.renderToStaticMarkup).join('');
    // console.log('MOVING PARTS', html);

    let content = this.props.editor.isEditable 
                ? (<DropZone className="dropzone" onDrop={this.handleFilesDrop}>
                    <ContentEditable refLink={createRandomNumber()} 
                                      html={html} 
                                      editor={this.props.editor}
                                      toolbar={this.props.toolbar}
                                      actions={this.props.actions}
                                      onChange={this.handleContentEditableChange} />
                    </DropZone>)
                : (dom);

    let imageToolbar = this.props.editor.showImageToolbar && this.props.editor.isEditable
                     ? (<ImageToolbar editor={this.props.editor} actions={this.props.actions} />)
                     : (null);

    return (
      <div className="re-box">
        <div className="re-box-content" onMouseOut={this.handleMouseOut}>
          {content}
          {imageToolbar}
        </div>
      </div>
    );
  }
});

export default Editable;