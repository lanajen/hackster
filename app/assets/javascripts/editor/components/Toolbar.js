import React from 'react';
import Button from './ToolbarButton';
import PopOver from './PopOver';
import _ from 'lodash';
import validator from 'validator';

const Toolbar = React.createClass({

  getInitialState() {
    return {
      toolbarTopPos: null,
      node: null,
      range: null,
      showPopOver: false
    };
  },

  componentDidMount() {
    if(window) {
      this.debouncedScroll = _.debounce(this.handleScroll, 10);
      window.addEventListener('scroll', this.debouncedScroll);
    }
  },

  componentWillUnmount() {
    if(window) {
      window.removeEventListener('scroll', this.debouncedScroll);
    }
  },

  handleScroll(e) {
    let el = React.findDOMNode(this.refs.toolbar);
    let scrollTop = el.getBoundingClientRect().top;
    let windowPos = window.pageYOffset;

    if(scrollTop <= 0 && this.state.toolbarTopPos === null) {
      el.classList.add('fixed-toolbar');

      this.setState({
        toolbarTopPos: windowPos
      }); 

    } else if (this.state.toolbarTopPos !== null && this.state.toolbarTopPos >= windowPos) {
      el.classList.remove('fixed-toolbar');

      this.setState({
        toolbarTopPos: null
      });
    }
  },

  createOrRemoveTag(tagType, valueArg) {
    if(document) {
      document.execCommand(tagType, false, valueArg);
    }
  },

  onNoValueArgButtonClick(tagType) {
    this.createOrRemoveTag(tagType, null);
  },

  onHasValueArgButtonClick(tagType, valueArg) {
    if(document.getSelection) {
      let node = document.getSelection();
      if(node.rangeCount) {
        let parentEl = this.getRootParentElement(node.anchorNode);
        if(node.anchorNode.parentNode.nodeName === valueArg || parentEl.nodeName === valueArg) {
          this.createOrRemoveTag(tagType, 'p');
        } else {
          this.createOrRemoveTag(tagType, valueArg);
        }
        node.collapseToEnd();
      }
    }
  },

  onLinkClick(tagType) {
    if(document.getSelection) {
      let node = document.getSelection();

      if((/^\w+$/).test(node.toString())) {
        let parentEl = this.getRootParentElement(node.anchorNode);

        if(node.anchorNode.parentNode.nodeName === 'A' || parentEl.nodeName === 'A') {
          // Edit link?
          this.createOrRemoveTag('unlink', 'p');
        } else {
          //  Creates PopOver and set it's props.
          this.setState({
            showPopOver: true,
            node: node,
            range: node.getRangeAt(0)
          });
        }
      }
    }
  },

  onLinkInput(value, node, range) {
    if(value === null) {
      return;
    } else {
      if(validator.isURL(value)) {
        node.removeAllRanges();
        node.addRange(range);
        this.createOrRemoveTag('createLink', value);
        node.collapseToEnd();
      } else {
        console.log('NOT A VALID URL');
      }
    }
  },

  unMountPopOver() {
    this.setState({
      showPopOver: false,
      node: null,
      range: null
    });
  },

  onImageButtonClick() {
    if(this.props.isImageBucketOpen) {
      this.props.hideFolder();
    } else {
      this.props.showFolder();
    }
  },

  getRootParentElement(anchorNode) {
    let parentEl, node = anchorNode;
    while(node.parentNode && node.parentNode.className !== 'box-content') {
      parentEl = node.parentNode;
      node = node.parentNode;
    }
    return parentEl;
  },


  render: function() {
    // console.log('TOOLBAR', this.props);
  
    let linkPopOver = this.state.showPopOver ? (
      <PopOver ref="popOver" node={this.state.node} range={this.state.range} onLinkInput={this.onLinkInput} unMountPopOver={this.unMountPopOver} />
    ) : null;

    return (
      <div ref="toolbar" className="btn-group react-editor-toolbar" role="group">
        <Button classList="btn-default" tagType="bold" icon="fa fa-bold" onClick={this.onNoValueArgButtonClick}/>
        <Button classList="btn-default" tagType="italic" icon="fa fa-italic" onClick={this.onNoValueArgButtonClick}/>
        <Button classList="btn-default" tagType="underline" icon="fa fa-underline" onClick={this.onNoValueArgButtonClick}/>
        <Button classList="btn-default" tagType="formatBlock" valueArg="BLOCKQUOTE" icon="fa fa-quote-right" onClick={this.onHasValueArgButtonClick}/>
        <Button classList="btn-default" tagType="createLink" icon="fa fa-link" onClick={this.onLinkClick}/>
        <Button classList="btn-default" tagType="formatBlock" valueArg="PRE" icon="fa fa-code" onClick={this.onHasValueArgButtonClick}/>
        <Button classList="btn-default" tagType="formatBlock" valueArg="H2" icon="fa fa-header" onClick={this.onHasValueArgButtonClick}/>
        <Button classList="btn-default" tagType="insertUnorderedList" icon="fa fa-list" onClick={this.onNoValueArgButtonClick}/>
        <Button classList="btn-default" tagType="insertOrderedList" icon="fa fa-list-ol" onClick={this.onNoValueArgButtonClick}/>
        <Button classList="btn-default" icon="fa fa-picture-o" onClick={this.onImageButtonClick} />
        {linkPopOver}
      </div>
    );
  }

});

export default Toolbar;