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
import Parser from '../utils/Parser';

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

  componentDidMount() {
    let panel = document.getElementById('story');
    let form = panel.querySelector('.simple_form');
    
    /** Issues the Toolbars notice of the CE width on resize. */
    window.addEventListener('resize', this.debouncedResize);

    /** Binds our callback when submit button is pressed. */
    form.addEventListener('pe:submit', this.handleSubmit);

    /** Append a story_json input to the hidden form. When the .pe-submit button is pressed, the value will get sent to the server. */
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
    let panel = document.getElementById('story');
    let form = panel.querySelector('.simple_form');

    form.removeEventListener('pe:submit', this.handleSubmit);
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
    return this.parseDOM(html)
      .then(parsedHTML => {
        this.props.actions.setDOM(parsedHTML, storeIndex, depth);
      })
      .catch(err => { console.log('Parse Error: ' + err); });
  },

  parseDOM(html) {
    return new Promise((resolve, reject) => {
      let handler = new DomHandler(function(err, dom) {
        if(err) console.log(err);

        let parsedHTML = this.parseTree(dom);
        resolve(parsedHTML);

      }.bind(this), { normalizeWhitespace: false });

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

  handleFilesDrop(storeIndex, files) {
    let node = Utils.getRootParentElement(this.props.editor.cursorPosition.node);
    let depth = Utils.findChildsDepthLevel(node, node.parentNode);
    
    ImageUtils.handleImagesAsync(files, function(map) {
      this.props.actions.createCarousel(map, depth, storeIndex);
      this.props.actions.forceUpdate(true);
    }.bind(this));
  },

  testP(string) {
    return new Promise((resolve, reject) => {
      resolve([string]);
    });
  },

  handleSubmit(e) {
    e.preventDefault();
    e.stopPropagation();

    let dom = this.props.editor.dom;
    let stringifiedJSON, item;

    let promised = dom.map(item => {
      /** Its super important to clone each item!  Otherwise we mutate the state of the store and bad things happen. */
      item = _.clone(item);

      if(item.type === 'CE') {
        stringifiedJSON = item.json.map(React.renderToStaticMarkup).join('');

        return this.parseDOM(stringifiedJSON)
          .then(json => {
            item.json = json;
            return Promise.resolve(item);
          });

      } else {
        return Promise.resolve(item);
      }
    });

    Promise.all(promised)
      .then(results => {
        let input = document.getElementById('story_json');
        input.value = JSON.stringify(results);
        /** Submit the hidden form (form is passed from projects.js via Custom Event).  Rails/jQuery takes care of the post request. */
        e.detail.form.submit();
        input.value = '';
      })
      .catch(err => {
        console.log(err);
      });
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