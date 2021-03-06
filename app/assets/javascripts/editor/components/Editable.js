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

    this.props.actions.setProjectData(this.props.projectId, this.props.modelType, this.props.S3BucketURL, this.props.AWSAccessKeyId);
    this.debouncedResize = _.debounce(this.handleResize, 30);

    if(!this.props.editor.dom.length) {
      this.props.actions.setIsFetching(true);
      this.props.actions.fetchInitialDOM(this.props.projectId);
    }
  },

  componentDidMount() {
    let form;
    switch(this.props.projectType) {
      case 'Project':
        form = document.querySelector('form.story-form');
        form.id = 'story-json';
        break;
      case 'Article':
        form = document.querySelector('form.description-form');
        form.id = 'story-json';
        break;
      default:
        break;
    }

    /** Issues the Toolbars notice of the CE width on resize. */
    window.addEventListener('resize', this.debouncedResize);

    /** Prevents browser backspace when body is targeted. */
    window.addEventListener('keydown', this.preventBackspace);

    //** Posts error logs to admin/logs. */
    window.onerror = this.handleGlobalError;

    /** Binds our callback when submit button is pressed. */
    form.addEventListener('pe:submit', this.handleSubmit);
    form.addEventListener('pe:complete', this.handleSubmitComplete);

    if(this.props.toolbar.CEWidth === null) {
      this.props.actions.setCEWidth(ReactDOM.findDOMNode(this).offsetWidth);
    }
  },

  componentWillUnmount() {
    let form;
    switch(this.props.projectType) {
      case 'Project':
        form = document.querySelector('form.story-form');
        form.id = 'story-json';
        break;
      case 'Article':
        form = document.querySelector('form.description-form');
        form.id = 'story-json';
        break;
      default:
        break;
    }

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

  componentWillReceiveProps(nextProps, nextState) {
    /** On tab navigation: if there was any change in the editor, we alter the $serializedForm so that window.pe
        will call its prompt.
      */
    if(nextProps.editor.hasUnsavedChanges && !this.props.editor.hasUnsavedChanges) {
      if(window && window.pe && window.$serializedForm) {
        window.$serializedForm += ' ';
        window.pe.showSavePanel();
      }
    }

    if(nextProps.editor.isDataLoading !== this.props.editor.isDataLoading) {
      if(window) {
        let container = document.querySelectorAll('.pe-save')[0];
        let button = container.querySelector('.pe-submit');
        if(nextProps.editor.isDataLoading) {
          button.innerText = 'Uploading image';
          button.setAttribute('disabled', true);
        } else if(!nextProps.editor.isDataLoading) {
          button.innerText = 'Save changes';
          button.removeAttribute('disabled');
        }
      }
    }
  },

  componentDidUpdate() {
    /** Adds editor store to history. */
    if(this.props.editor.domUpdated === true) {
      let history = this.props.history;
      let lastState = history.redoStore.length ? history.redoStore[history.redoStore.length - 1] : history.undoStore[history.undoStore.length - 1];
      this.props.actions.updateHistory(_.cloneDeep(this.props.editor));
      this.props.actions.domUpdated(false);
    }

    if(this.props.editor.replaceLastInUndoStore === true) {
      this.props.actions.toggleFlag('replaceLastInUndoStore', false);
      this.props.actions.replaceLastInUndoStore(_.cloneDeep(this.props.editor));
    }
  },

  handleGlobalError(msg, url, line, col, obj) {
    let date = new Date();

    if(msg && msg.length) {
      this.props.actions.postErrorLog({
        browser: this.props.browser,
        msg: msg,
        projectId: this.props.editor.projectId,
        stack: obj ? obj.stack : {},
        timeStamp: date.toTimeString(),
        userAgent: window.navigator && window.navigator.userAgent ? window.navigator.userAgent : null
      });
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

  handleContentEditableChange(html, depth, storeIndex, cursorData) {
    return Parser.parseDOM(html)
      .then(parsedHTML => {
        this.props.actions.setNewDOM(parsedHTML, depth, storeIndex, cursorData);
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
        this.props.editor.projectId,
        this.props.editor.modelType
      );

    });
  },

  handleSubmit(e) {
    e.preventDefault();
    e.stopPropagation();

    let promised = this.props.editor.dom.map(domItem => {
      /** Its super important to clone each item!  Otherwise we mutate the state of the store and bad things happen. */
      let item = _.cloneDeep(domItem);
      let cleaned;

      if(item.type === 'CE') {
        cleaned = Parser.removeAttributes(item.json);
        cleaned = Parser.concatPreBlocks(cleaned);
        cleaned = Parser.postCleanUp(cleaned);
        item.json = cleaned;
        delete item.html;
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
        return !item.images.length ? null : Promise.resolve(item);
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
          /** Appends a story_json input to the hidden form. */
          let form = document.getElementById('story-json');
          let input = document.createElement('input');
          input.type = 'hidden';
          input.name = 'base_article[story_json]';
          input.id = 'story-json-input';
          input.value = JSON.stringify(results);
          form.insertBefore(input, form.firstChild);

          /** Submit the hidden form (form is passed from projects.js via Custom Event).  Rails/jQuery takes care of the post request. */
          e.detail.form.submit();
          this.props.actions.hasUnsavedChanges(false);
        }
      })
      .catch(err => {
        this.props.actions.toggleErrorMessenger(true, 'Bummer, the project didn\'t save correctly.');
      });
  },

  handleSubmitComplete(e) {
    let form = document.getElementById('story-json');
    let input = document.getElementById('story-json-input');
    form.contains(input) ? form.removeChild(input) : false;

    /** Reserialize the form so pe && jQuery know we have NO unsaved changes. **/
    if (window && window.pe) {
      window.pe.serializeForm();
      window.pe.updateChecklist();
    }

    this.props.actions.toggleErrorMessenger(true, 'Saved successfully!', 'success');
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
        let html = item.html ? item.html : Parser.toHtml(item.json);
        return (<DropZone key={index} className="dropzone" onDrop={this.handleFilesDrop.bind(this, index)}>
                  <ContentEditable html={html}
                                   browser={this.props.browser}
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