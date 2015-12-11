import React from 'react/addons';
import { bindActionCreators } from 'redux';
import { connect } from 'react-redux';
import Toolbar from './Toolbar';
import Editable from './Editable';
import { Snackbar } from 'material-ui';
import * as ToolbarActions from '../actions/toolbar';
import * as EditorActions from '../actions/editor';
import { createRandomNumber } from '../../utils/Helpers';
import injectTapEventPlugin from 'react-tap-event-plugin';
import { ThemeManager, LightRawTheme } from 'material-ui/lib/styles';
import { Dialog, IconButton } from 'material-ui';
import browser from 'detect-browser';

/** This can be removed when React1.0 is released. */
injectTapEventPlugin();

const PureRenderMixin = React.addons.PureRenderMixin;

const Editor = React.createClass({
  mixins: [PureRenderMixin],

  childContextTypes: {
    muiTheme: React.PropTypes.object
  },

  getChildContext() {
    return {
      muiTheme: ThemeManager.getMuiTheme(LightRawTheme)
    };
  },

  componentWillMount() {
    if(browser.name === 'ie') {
      this.props.actions.toggleIE(true);
    }
  },

  componentDidMount() {
    if(browser.name === 'ie' && parseInt(browser.version, 10) < 11) {
      this.refs.browserSupport.show();
    }
  },

  componentWillReceiveProps(nextProps) {
    if(nextProps.editor.errorMessenger.show) {
      this.refs.errorMessenger.show();
    }
  },

  handleErrorMessengerDismiss() {
    this.props.actions.toggleErrorMessenger(false, '');
  },

  handleOnMessageTouch() {
    this.refs.errorMessenger.dismiss();
  },

  handleIconClick(browser, e) {
    e.preventDefault();
    let browsers = {
      'chrome': 'https://www.google.com/chrome/browser/',
      'firefox': 'https://www.mozilla.org/en-US/firefox/new/',
      'edge': 'https://www.microsoft.com/en-us/windows/microsoft-edge'
    };

    if(window) {
      window.open(browsers[browser], '_blank');
    }
  },

  render() {
    if(this.props.hashLocation !== '#story') {
      return null;
    }

    let dialogActions = [{ text: 'Cool beans?', ref: "closeDialog" }];
    let dialogBody = (
      <div style={{ textAlign: 'center' }}>
        <h4>Woops, seems like your using an unsupported browser.  Please update to one of these:</h4>
        <IconButton iconClassName="fa fa-chrome" iconStyle={{ color: '#FDD835' }} tooltip="Chrome" onClick={this.handleIconClick.bind(this, 'chrome')}></IconButton>
        <IconButton iconClassName="fa fa-firefox" iconStyle={{ color: '#ef5350' }} tooltip="Firefox" onClick={this.handleIconClick.bind(this, 'firefox')}></IconButton>
        <IconButton iconClassName="fa fa-windows" iconStyle={{ color: 'steelblue' }} tooltip="Edge" onClick={this.handleIconClick.bind(this, 'edge')}></IconButton>
      </div>
    );

    return (
      <div className="react-editor-wrapper">
        <div className="react-editor-toolbar-container">
          <Toolbar hashLocation={this.props.hashLocation} />
        </div>
        <Editable className="box" refLink={createRandomNumber()} hashLocation={this.props.hashLocation} {...this.props} />
        <Dialog ref="browserSupport" actions={dialogActions} actionFocus="closeDialog" modal={false}>{dialogBody}</Dialog>
        <Snackbar style={{zIndex: 10001}} ref="errorMessenger" message={this.props.editor.errorMessenger.msg} action={this.props.editor.errorMessenger.actionIcon} autoHideDuration={5000} onActionTouchTap={this.handleOnMessageTouch} onDismiss={this.handleErrorMessengerDismiss} />
      </div>
    );
  }
});

function mapStateToProps(state) {
  return {
    editor: state.editor
  };
}

function mapDispatchToProps(dispatch) {
  return { actions: bindActionCreators(EditorActions, dispatch) };
}

export default connect(mapStateToProps, mapDispatchToProps)(Editor);