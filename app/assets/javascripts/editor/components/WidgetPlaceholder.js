import React from 'react';

const WidgetPlaceholder = React.createClass({

  getInitialState() {
    return {
      hovered: false,
      height: null,
      overlayStyles: {}
    };
  },

  componentWillMount() {
    if(this.props.widgetData.widgetType === 'twitter' && window) {
      window.addEventListener('message', this.handleMessage);
    }
  },

  componentDidMount() {
    if(this.props.widgetData.widgetType !== 'twitter') {
      let height = React.findDOMNode(this).height;
      this.setState({ height: height, overlayStyles: this.getOverlayStyles(height) });
    }
  },

  componentWillUnmount() {
    if(this.props.widgetData.widgetType === 'twitter' && window) {
      window.removeEventListener('message', this.handleMessage);
    }
  },

  handleMessage(e) {
    if(e.origin !== 'https://twitframe.com' || parseInt(e.data.element, 10) !== parseInt(this.props.widgetData.id, 10)) { return; }

    this.setState({ height: parseInt(e.data.height, 10), overlayStyles: this.getOverlayStyles(e.data.height) });

    if(window && window.pe) { window.pe.resizePeContainer(); }
  },

  toggleHover(hovered) {
    this.setState({
      hovered: hovered
    });
  },

  handleWidgetDeletion() {
    this.props.deleteWidget(this.props.storeIndex);
  },

  handleIFrameLoad() {
    let iframe = React.findDOMNode(this.refs.iframe);
    iframe.contentWindow.postMessage({ element: this.props.widgetData.id, query: 'height' }, 'https://twitframe.com');
  },

  getOverlayStyles(height) {
    let underlay = React.findDOMNode(this).firstChild;

    return {
      height: height,
      width: underlay.width,
      left: underlay.offsetLeft,
      position: 'absolute'
    };
  },

  render: function() {
    let data = this.props.widgetData;
    let widgetTypes = {
      'parts_widget': 'Parts List',
      'bitbucket-widget': 'Bitbucket Repo',
      'github-widget': 'Github Repo',
      'old_code_widget': 'Old Code Widget',
      'twitter': 'Tweet'
    };
    let rootClassName = data.widgetType === 'twitter' ? 'react-editor-widget-placeholder twitter' : 'react-editor-widget-placeholder';

    let type = <span className="text-danger">{widgetTypes[data.widgetType]}</span>
    let tweet = <span style={{ color: 'lightblue' }}>tweet</span>

    let placeholder = data.widgetType === 'twitter'
                    ? (<iframe ref="iframe" id={data.id} border="0" frameBorder="0" height={this.state.height} width="550" src={`https://twitframe.com/show?${data.embed}`} onLoad={this.handleIFrameLoad}></iframe>)
                    : (<h3>Apologies, {type} is now deprecated in the Story section.</h3>);

    let overlay = this.state.hovered
                ? (<div style={this.state.overlayStyles} className="widget-placeholder-overlay">
                    <button style={{ fontSize: '1.25em' }} className="fa fa-trash-o btn btn-danger" onClick={this.handleWidgetDeletion}></button>
                  </div>)
                : (null);

    return (<div className={rootClassName} data-hash={this.props.hash} onMouseEnter={this.toggleHover.bind(this, true)} onMouseLeave={this.toggleHover.bind(this, false)}>
              {placeholder}
              {overlay}
            </div>);
  }

});

export default WidgetPlaceholder;