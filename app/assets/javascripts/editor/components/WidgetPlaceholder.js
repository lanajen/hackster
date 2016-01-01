import React from 'react';
import ReactDOM from 'react-dom';

const WidgetPlaceholder = React.createClass({

  getInitialState() {
    return {
      hovered: false,
      height: null,
      overlayStyles: {},
      widgetType: null,
      id: null
    };
  },

  componentWillMount() {
    if(window) {
      window.addEventListener('message', this.handleMessage);
    }
  },

  componentDidMount() {
    if(this.props.widgetData.widgetType !== 'twitter') {
      let styles = this.getRootOverlayStyles();
      this.setState({
        height: styles.height,
        overlayStyles: styles,
        widgetType: this.props.widgetData.widgetType
      });
    } else {
      this.setState({ widgetType: 'twitter', id: this.props.widgetData.id });
    }
  },

  componentWillUnmount() {
    if(window) {
      window.removeEventListener('message', this.handleMessage);
    }
  },

  componentDidUpdate(nextProps) {
    if(nextProps.widgetData.widgetType !== 'twitter' && this.state.widgetType === 'twitter') {
      let styles = this.getRootOverlayStyles();
      this.setState({ height: styles.height, overlayStyles: styles });
    }

    if(this.state.widgetType !== nextProps.widgetData.widgetType) {
      this.setState({ widgetType: nextProps.widgetData.widgetType });
    }
  },

  componentWillReceiveProps(nextProps) {
    if(this.state.id !== nextProps.widgetData.id) {
      this.setState({ id: nextProps.widgetData.id, height: null });
    }
  },

  handleMessage(e) {
    e.preventDefault();
    if(e.origin !== 'https://twitframe.com' || parseInt(e.data.element, 10) !== parseInt(this.props.widgetData.id, 10)) { return; }

    let height = this.state.height === null ? parseInt(e.data.height, 10) : parseInt(e.data.height, 10) - 20;
    this.setState({ height: height, overlayStyles: this.getIFrameOverlayStyles(height) });

    if(window && window.pe) { window.pe.resizePeContainer(); }
  },

  toggleHover(hovered) {
    let styles = this.state.widgetType === 'twitter' ? this.getIFrameOverlayStyles(this.state.height) : this.getRootOverlayStyles();
    this.setState({
      hovered: hovered,
      height: styles.height,
      overlayStyles: styles
    });
  },

  handleWidgetDeletion(e) {
    e.preventDefault();
    e.stopPropagation();

    this.props.deleteWidget(this.props.storeIndex);
    this.setState({
      hovered: false
    });
  },

  handleIFrameLoad() {
    let iframe = ReactDOM.findDOMNode(this.refs.iframe);
    iframe.contentWindow.postMessage({ element: this.props.widgetData.id, query: 'height' }, 'https://twitframe.com');
  },

  getIFrameOverlayStyles(height) {
    let iframe = ReactDOM.findDOMNode(this.refs.iframe);
    return {
      height: height || iframe.offsetHeight,
      width: iframe.offsetWidth,
      left: iframe.offsetLeft,
      position: 'absolute'
    };
  },

  getRootOverlayStyles() {
    let el = ReactDOM.findDOMNode(this);
    return {
      height: el.offsetHeight,
      width: el.offsetWidth,
      left: el.offsetLeft,
      marginTop: '-10px', // H3 has a global style on them, this sets it back to normal.
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
                    ? (<iframe ref="iframe" id={data.id} border="0" frameBorder="0" height={this.state.height} width="500" src={`https://twitframe.com/show?${data.embed}`} onLoad={this.handleIFrameLoad}></iframe>)
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