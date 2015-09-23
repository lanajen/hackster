import React from 'react/addons';
import _ from 'lodash';
import DropZone from '../../reusable_components/DropZone';
import ContentEditable from './ContentEditable';
import Carousel from './Carousel';
import Video from './Video';
import File from './File';
import ImageToolbar from './ImageToolbar';
import { createRandomNumber } from '../../utils/Helpers';
import Utils from '../utils/DOMUtils';
import ImageUtils from '../../utils/Images';
import Validator from 'validator';
import HtmlParser from 'htmlparser2';
import DomHandler from 'domhandler';

const Editable = React.createClass({

  componentWillMount() {
    let metaList = document.getElementsByTagName('meta');
    let csrfToken = _.findWhere(metaList, {name: 'csrf-token'}).content;
    let projectId = window.location.href.match(/\/[\d]+/).join('').slice(1);

    this.props.actions.setProjectData(projectId, csrfToken, this.props.S3BucketURL, this.props.AWSAccessKeyId);
    this.debouncedResize = _.debounce(this.handleResize, 30);
    
    if(!this.props.editor.dom.length) {
      this.props.actions.setIsFetching(true);
      this.props.actions.fetchInitialDOM(projectId, csrfToken);
    }
  },

  tester() { console.log('fucking work!'); },

  componentDidMount() {
    /** Issues the Toolbars notice of the CE width on resize. */
    window.addEventListener('resize', this.debouncedResize);
    let button = document.querySelector('.pe-submit');
    button.addEventListener('pe:submit', this.tester);

    /** Append a story_json input to the hidden form. When the .pe-submit button is pressed, the value will get sent to the server. */
    let form = document.getElementById('story').children[0];
    if(document.getElementById('story_json') === null) {
      let input = document.createElement('input');
      input.type = 'hidden';
      input.id = 'story_json';
      input.name = 'project[story_json]';
      form.insertBefore(input, form.firstChild);
    }

    if(this.props.toolbar.CEWidth === null) {
      this.props.actions.setCEWidth(React.findDOMNode(this).offsetWidth);
    }
  },

  componentWillUnmount() {
    window.removeEventListener('resize', this.debouncedResize);
  },

  componentWillUpdate() {
    /** Sets initial CEWidth for the Toolbars. */
    if(this.props.toolbar.CEWidth === 0) {
      this.props.actions.setCEWidth(React.findDOMNode(this).offsetWidth);
    }
  },

  handleResize() {
    this.props.actions.toggleImageToolbar(false, {});
    this.props.actions.setCEWidth(React.findDOMNode(this).offsetWidth);
  },

  handleContentEditableChange(storeIndex, html, depth) {
    let promise = this.parseDOM(html);
    promise.then(function(parsedHTML) {
      this.props.actions.setDOM(parsedHTML, storeIndex, depth);
    }.bind(this)).catch(function(err) { console.log('Parse Error: ' + err); });
  },

  parseDOM(html) {
    return new Promise((resolve, reject) => {
      let handler = new DomHandler(function(err, dom) {
        if(err) console.log(err);
        
        let parsedHTML = this.parseTree(dom);
        resolve(parsedHTML);

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

  handleFilesDrop(storeIndex, files) {
    let node = Utils.getRootParentElement(this.props.editor.cursorPosition.node);
    let depth = Utils.findChildsDepthLevel(node, node.parentNode);
    
    ImageUtils.handleImagesAsync(files, function(map) {
      this.props.actions.createCarousel(map, depth, storeIndex);
      this.props.actions.forceUpdate(true);
    }.bind(this));
  },

  render() {
    /** Temp fix for Rails router pagination.  This block should never get hit;  its parent (Editor Container) should handle the cancellation. */
    if(this.props.hashLocation !== '#story') {
      return null;
    }

    let dom = this.props.editor.dom;
    let content = dom.map((item, index) => {
      let html;
      if(item.type === 'CE') {
        html = item.json.map(React.renderToStaticMarkup).join(''); 
        return (<DropZone key={index} className="dropzone" onDrop={this.handleFilesDrop.bind(this, index)}>
                  <ContentEditable html={html} 
                                   storeIndex={index} 
                                   editor={this.props.editor} 
                                   actions={this.props.actions} 
                                   hash={item.hash} 
                                   onChange={this.handleContentEditableChange.bind(this, index)} />
                </DropZone>);
      } else if(item.type === 'Carousel') {
        return <Carousel key={index} storeIndex={index} images={item.images} hash={item.hash} editor={this.props.editor} actions={this.props.actions} />
      } else if(item.type === 'Video'){
        return <Video key={index} storeIndex={index} videoData={item.images} hash={item.hash} editor={this.props.editor} actions={this.props.actions} />
      } else if(item.type === 'File') {
        return <File key={index} storeIndex={index} fileData={item.data} hash={item.hash} editor={this.props.editor} actions={this.props.actions} />
      } else {
        return null;
      }
    });

    let imageToolbar = this.props.editor.showImageToolbar && this.props.editor.isEditable
                     ? (<ImageToolbar editor={this.props.editor} actions={this.props.actions} />)
                     : (null);

    let mainContent = this.props.editor.isFetching
                    ? (<div style={{ textAlign: 'center', padding: '5%' }}><i className="fa fa-spin fa-spinner fa-3x"></i>LOADING...</div>)
                    : content;

    return (
      <div className="box">
        <div className="box-content">
          {mainContent}
        </div>
        {imageToolbar}
      </div>
    );
  }
});

export default Editable;