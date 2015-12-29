import React from 'react';
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
import { Dialog, IconButton, FlatButton } from 'material-ui';
import browser from 'detect-browser';

/** This can be removed when React1.0 is released. */
injectTapEventPlugin();

const Editor = React.createClass({

  getInitialState() {
    return {
      openDialog: false
    };
  },

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
      this.setState({ openDialog: true });
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

  handleDialogClose() {
    this.setState({ openDialog: false });
  },

  render() {
    if(this.props.hashLocation !== '#story') {
      return null;
    }

    let dialogActions = [
      <FlatButton
        key={0}
        label="Cool Beans?"
        primary={false}
        onTouchTap={this.handleDialogClose} />
    ];
    let dialogBody = (
      <div style={{ textAlign: 'center' }}>
        <h4>Woops, seems like your using an unsupported browser.  Please update to one of these:</h4>
        <IconButton iconClassName="fa fa-chrome" iconStyle={{ color: '#FDD835' }} tooltip="Chrome" onClick={this.handleIconClick.bind(this, 'chrome')}></IconButton>
        <IconButton iconClassName="fa fa-firefox" iconStyle={{ color: '#ef5350' }} tooltip="Firefox" onClick={this.handleIconClick.bind(this, 'firefox')}></IconButton>
        <IconButton iconClassName="fa fa-edge" iconStyle={{ color: 'steelblue' }} tooltip="Edge" onClick={this.handleIconClick.bind(this, 'edge')}></IconButton>
      </div>
    );

    return (
      <div className="react-editor-wrapper">
        <div className="react-editor-toolbar-container">
          <Toolbar hashLocation={this.props.hashLocation} />
        </div>
        <Editable {...this.props} />
        <Dialog actions={dialogActions} actionFocus="closeDialog" open={this.state.openDialog}>{dialogBody}</Dialog>
        <Snackbar style={{zIndex: 10001, maxWidth: '100%'}} ref="errorMessenger" message={this.props.editor.errorMessenger.msg} action={this.props.editor.errorMessenger.actionIcon} autoHideDuration={5000} onActionTouchTap={this.handleOnMessageTouch} onDismiss={this.handleErrorMessengerDismiss} />
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