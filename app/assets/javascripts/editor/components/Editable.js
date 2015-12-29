import React from 'react';
import ReactDOM from 'react-dom';
import _ from 'lodash';
import DropZone from '../../reusable_components/DropZone';
import ContentEditable from './ContentEditable';
import Carousel from './Carousel';
import Video from './Video';
import File from './File';
import Placeholder from './Placeholder';
import WidgetPlaceholder from './WidgetPlaceholder';
import ImageToolbar from './ImageToolbar';
import { createRandomNumber } from '../../utils/Helpers';
import Utils from '../utils/DOMUtils';
import ImageUtils from '../../utils/Images';
import Parser from '../utils/Parser';

const Editable = React.createClass({

  componentWillMount() {
    let metaList = document.getElementsByTagName('meta');
    let csrfToken = _.findWhere(metaList, {name: 'csrf-token'}).content;
    let projectId = Utils.getWindowLocationHref().match(/\/[\d]+/).join('').slice(1);

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

    /** Prevents browser backspace when body is targeted. */
    window.addEventListener('keydown', this.preventBackspace);

    /** Binds our callback when submit button is pressed. */
    form.addEventListener('pe:submit', this.handleSubmit);

    /** Append a story_json input to the hidden form. When the .pe-submit button is pressed, the value will get sent to the server. */
    if (document.getElementById('story_json') === null) {
      let input = document.createElement('input');
      input.type = 'hidden';
      input.id = 'story_json';
      input.name = 'base_article[story_json]';
      form.insertBefore(input, form.firstChild);

      /** $.serialize() turns the form into a string.  Since we're adding a new input, unsavedChanges will force a prompt if user
        * tries to tab navigate away without changes made.  This will update the $form so that doesn't trigger.
        */
      if(window.pe) {
        window.pe.serializeForm();
      }
    }

    if(this.props.toolbar.CEWidth === null) {
      this.props.actions.setCEWidth(ReactDOM.findDOMNode(this).offsetWidth);
    }
  },

  componentWillUnmount() {
    let panel = document.getElementById('story');
    let form = panel.querySelector('.simple_form');

    form.removeEventListener('pe:submit', this.handleSubmit);
    window.removeEventListener('resize', this.debouncedResize);
    window.removeEventListener('keydown', this.preventBackspace);
    this.props.actions.hasUnsavedChanges(false);
  },

  componentWillUpdate() {
    /** Sets initial CEWidth for the Toolbars. */
    if(this.props.toolbar.CEWidth === 0) {
      this.props.actions.setCEWidth(ReactDOM.findDOMNode(this).offsetWidth);
    }

    if(window && window.pe) { window.pe.resizePeContainer(); }
  },

  componentWillReceiveProps(nextProps) {
    /** On tab navigation: if there was any change in the editor, we alter the input#story so that window.pe
        will see that theres a difference in the serialized vs altered form and call its prompt.
      */
    if(nextProps.editor.hasUnsavedChanges && !this.props.editor.hasUnsavedChanges) {
      if(window.pe) {
        let input = document.getElementById('story_json');
        input.value = 'true';
        window.pe.showSavePanel();
      }
    }
  },

  handleResize() {
    this.props.actions.toggleImageToolbar(false, {});
    this.props.actions.setCEWidth(ReactDOM.findDOMNode(this).offsetWidth);
  },

  preventBackspace(e) {
    if(e.keyCode === 8 && e.target.nodeName === 'BODY') {
      e.preventDefault();
    }
  },

  handleContentEditableChange(html, depth, storeIndex) {
    return Parser.parseDOM(html)
      .then(parsedHTML => {
        this.props.actions.setDOM(parsedHTML, depth, storeIndex);
      })
      .catch(err => { console.log('Editable.js Parse Error: ' + err); });
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
    let dom = JSON.parse(JSON.stringify(this.props.editor.dom));
    let stringifiedJSON, item, cleaned;

    let promised = dom.map(item => {
      /** Its super important to clone each item!  Otherwise we mutate the state of the store and bad things happen. */
      item = _.clone(item);

      if(item.type === 'CE') {
        cleaned = Parser.removeAttributes(item.json);
        cleaned = Parser.concatPreBlocks(cleaned);
        cleaned = Parser.postCleanUp(cleaned);
        item.json = cleaned;
        return Promise.resolve(item);
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
            service: v.service || null,
            type: v.type || null
          };
        });
        item.video = cleaned;
        return Promise.resolve(item);
      } else if(item.type === 'Placeholder') {
        return null;
      } else {
        return Promise.resolve(item);
      }
    }).filter(item => { return item !== null; });

    Promise.all(promised)
      .then(results => {
        if(!Array.isArray(results)) {
          this.props.actions.toggleErrorMessenger(true, 'Bummer, the project didn\'t save correctly.');
        } else {
          let input = document.getElementById('story_json');
          input.value = JSON.stringify(results);
          /** Submit the hidden form (form is passed from projects.js via Custom Event).  Rails/jQuery takes care of the post request. */
          e.detail.form.submit();
          input.value = '[]';
          this.props.actions.hasUnsavedChanges(false);
        }
      })
      .catch(err => {
        this.props.actions.toggleErrorMessenger(true, 'Bummer, the project didn\'t save correctly.');
      });
  },

  handlePlaceholderClick(storeIndex) {
    this.props.actions.insertCE(storeIndex);
  },

  handleDeleteWidget(storeIndex) {
    this.props.actions.deleteComponent(storeIndex);
  },

  render() {
    let dom = this.props.editor.dom || [{ type: 'CE', json: [] }];
    let content = dom.map((item, index) => {
      if(item.type === 'CE') {
        let html = Parser.toHtml(item.json);
        return (<DropZone key={index} className="dropzone" onDrop={this.handleFilesDrop.bind(this, index)}>
                  <ContentEditable html={html}
                                   storeIndex={index}
                                   editor={this.props.editor}
                                   actions={this.props.actions}
                                   hash={item.hash}
                                   onChange={this.handleContentEditableChange} />
                </DropZone>);
      } else if(item.type === 'Carousel') {
        return <Carousel key={index} storeIndex={index} images={item.images} hash={item.hash} editor={this.props.editor} actions={this.props.actions} />
      } else if(item.type === 'Video'){
        return <Video key={index} storeIndex={index} videoData={item.video} hash={item.hash} editor={this.props.editor} actions={this.props.actions} />
      } else if(item.type === 'File') {
        return <File key={index} storeIndex={index} fileData={item.data} hash={item.hash} editor={this.props.editor} actions={this.props.actions} />
      } else if(item.type === 'Placeholder') {
        return <Placeholder key={index} storeIndex={index} hash={item.hash} insertCE={this.handlePlaceholderClick} />
      } else if (item.type === 'WidgetPlaceholder') {
        return <WidgetPlaceholder key={index} storeIndex={index} widgetData={item.data} hash={item.hash} deleteWidget={this.handleDeleteWidget}/>
      } else {
        return null;
      }
    }).filter(item => item !== null);

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