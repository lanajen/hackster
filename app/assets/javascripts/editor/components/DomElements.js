import React from 'react';
import { createRandomNumber } from '../../utils/Helpers';
import Utils from '../utils/DOMUtils';

export const ELEMENT = React.createClass({
  render() {
    return React.createElement(this.props.tagProps.tag, {['data-hash']: this.props.tagProps.hash}, [...this.props.children]);
  }
});

export const P = React.createClass({
  render() {
    return (
      <p style={this.props.style} className={this.props.className} data-hash={this.props.tagProps.hash}>{this.props.children}</p>
    );
  }
});

export const A = React.createClass({
  render() {
    return (
      <a className={this.props.className} href={this.props.tagProps.href}>{this.props.children}</a>
    );
  }
});

export const PRE = React.createClass({
  render() {
    return (
      <pre data-hash={this.props.tagProps.hash}>{this.props.children}</pre>
    );
  }
});

export const BLOCKQUOTE = React.createClass({
  render() {
    return (
      <blockquote className={this.props.className} data-hash={this.props.tagProps.hash}>{this.props.children}</blockquote>
    );
  }
});

export const DIV = React.createClass({
  render() {
    let style = this.props.style || {},
        CE = null;

    if(this.props.className === 'reit-controls' || this.props.className === 'video-mask fa fa-youtube-play') {
      CE = false;
    }

    return (
      <div style={style} className={this.props.className} data-hash={this.props.tagProps.hash} contentEditable={CE}>{this.props.children}</div>
    );
  }
});

export const UL = React.createClass({
  render() {
    let children = this.props.children !== null ? this.props.children.map(function(child, index) {
      let newChildren = child.props.children;
      return <li key={createRandomNumber()}>{newChildren}</li>
    }) : this.props.children;
    return (
      <ul className={this.props.className} data-hash={this.props.tagProps.hash}>{children}</ul>
    )
  }
});

export const FIGURE = React.createClass({
  render() {
    let tagProps = this.props.tagProps;

    return (
      <figure className={this.props.className} data-hash={tagProps.hash} data-type={tagProps.type}>{this.props.children}</figure>
    );
  }
});

export const FIGCAPTION = React.createClass({
  render() {
    let tagProps = this.props.tagProps;

    return (
      <figcaption style={this.props.style} className={this.props.className}>{this.props.children}</figcaption>
    );
  }
});

export const IMG = React.createClass({
  render() {
    let tagProps = this.props.tagProps;
    let imgSrc = tagProps.src ? tagProps.src : tagProps.dataSrc;
    return (
      <img style={this.props.style} className={this.props.className} data-src={tagProps.dataSrc} src={imgSrc} alt={tagProps.alt} />
    );
  }
});

export const IFRAME = React.createClass({
  render() {
    return (
      <iframe data-hash={this.props.tagProps.hash} src={this.props.tagProps.src}>{this.props.children}</iframe>
    );
  }
});

export const CAROUSEL = React.createClass({
  render() {
    let tagProps = this.props.tagProps;
    let children = this.props.children;
    let controls = children[0] && children[0].props.children && children[0].props.children.length > 1 
                 ? (<div key={createRandomNumber()} className="reit-controls" contentEditable={false}>
                      <button className="reit-controls-button left fa fa-chevron-left fa-2x"></button>
                      <button className="reit-controls-button right fa fa-chevron-right fa-2x"></button>
                    </div>)
                 : (null);
    /** Sets the controls to prevent duplication. */
    children[1] = controls;

    return (
      <div style={this.props.style} className={this.props.className} data-hash={tagProps.hash} data-type="carousel">
        {children}
      </div>
    );
  }
});

export const VIDEO = React.createClass({
  render() {
    return (
      <div style={this.props.style} className={this.props.className} data-hash={this.props.tagProps.hash} data-type="video" data-video-id={this.props.tagProps['data-video-id']}>
        {this.props.children}
      </div>
    );
  }
});