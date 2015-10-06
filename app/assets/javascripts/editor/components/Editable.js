import React from 'react/addons';
import _ from 'lodash';
import Validator from 'validator';
import HtmlParser from 'htmlparser2';
import DomHandler from 'domhandler';
import DropZone from '../../reusable_components/DropZone';
import ContentEditable from './ContentEditable';
import Carousel from './Carousel';
import Video from './Video';
import File from './File';
import ImageToolbar from './ImageToolbar';
import { createRandomNumber } from '../../utils/Helpers';
import Utils from '../utils/DOMUtils';
import ImageUtils from '../../utils/Images';
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
    return Parser.parseDOM(html)
      .then(parsedHTML => {
        this.props.actions.setDOM(parsedHTML, storeIndex, depth);
      })
      .catch(err => { console.log('Parse Error: ' + err); });
  },

  handleFilesDrop(storeIndex, files) {

    /** DropZone.js handles filtering for images, it'll return an empty array if all wasn't valid. */
    if(!files.length) {
      return;
    }

    let node = Utils.getRootParentElement(this.props.editor.cursorPosition.node);
    let depth = Utils.findChildsDepthLevel(node, node.parentNode);
    
    ImageUtils.handleImagesAsync(files, map => {
      let storeIndex = this.props.editor.currentStoreIndex;
      this.props.actions.isDataLoading(true);
      this.props.actions.createMediaByType(map, depth, storeIndex, 'Carousel');
      this.props.actions.forceUpdate(true);

      /** Upload files to AWS. */
      this.props.actions.uploadImagesToServer(
        map,
        storeIndex, 
        this.props.editor.lastMediaHash,
        this.props.editor.S3BucketURL, 
        this.props.editor.AWSAccessKeyId, 
        this.props.editor.csrfToken, 
        this.props.editor.projectId
      );

    });
  },

  handleSubmit(e) {
    e.preventDefault();
    e.stopPropagation();

    let dom = this.props.editor.dom;
    let stringifiedJSON, item, cleaned;

    let promised = dom.map(item => {
      /** Its super important to clone each item!  Otherwise we mutate the state of the store and bad things happen. */
      item = _.clone(item);

      if(item.type === 'CE') {
        stringifiedJSON = item.json.map(React.renderToStaticMarkup).join('');

        return Parser.parseDOM(stringifiedJSON)
          .then(json => {
            cleaned = Parser.removeAttributes(json);
            item.json = cleaned;
            return Promise.resolve(item);
          });

      } else if(item.type === 'Carousel') {
        let images = _.clone(item.images);
        cleaned = images.map(image => {
          return {
            id: image.id,
            figcaption: image.figcaption,
            uuid: image.uuid,
            name: image.name,
            url: null
          };
        }).filter(image => { return !image.id ? false : true; });
        item.images = cleaned;
        return Promise.resolve(item);
      } else if(item.type === 'Video') {
        let video = _.clone(item.video);
        cleaned = video.map(v => {
          return {
            id: v.id,
            figcaption: v.figcaption,
            embed: v.embed,
            service: v.service
          };
        });
        item.video = cleaned;
        return Promise.resolve(item);
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
        this.props.actions.toggleErrorMessenger(true, 'Bummer, the project didn\'t save correctly.');
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
        return <Video key={index} storeIndex={index} videoData={item.video} hash={item.hash} editor={this.props.editor} actions={this.props.actions} />
      } else if(item.type === 'File') {
        return <File key={index} storeIndex={index} fileData={item.data} hash={item.hash} editor={this.props.editor} actions={this.props.actions} />
      } else {
        return null;
      }
    });

    let mainContent = this.props.editor.isFetching
                    ? (<div style={{ textAlign: 'center', padding: '5%' }}><i className="fa fa-spin fa-spinner fa-3x"></i>LOADING...</div>)
                    : content;

    return (
      <div className="box">
        <div className="box-content">
          {mainContent}
        </div>
      </div>
    );
  }
});

export default Editable;