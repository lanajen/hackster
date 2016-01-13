import React from 'react';
import { bindActionCreators } from 'redux';
import { connect } from 'react-redux';
import Toolbar from './Toolbar';
import Editable from './Editable';
import * as ToolbarActions from '../actions/toolbar';
import * as EditorActions from '../actions/editor';
import { createRandomNumber } from '../../utils/Helpers';
import injectTapEventPlugin from 'react-tap-event-plugin';
import { ThemeManager, LightRawTheme } from 'material-ui/lib/styles';
import { Dialog, IconButton, FlatButton, Snackbar } from 'material-ui';
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

  handleErrorMessengerDismiss() {
    this.props.actions.toggleErrorMessenger(false, '');
  },

  handleOnMessageTouch() {
    this.handleErrorMessengerDismiss();
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
    if(this.props.projectType === 'Project' && this.props.hashLocation !== '#story') {
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
        <Editable { ...this.props } />
        <Dialog actions={dialogActions} open={this.state.openDialog} onRequestClose={this.handleDialogClose}>{dialogBody}</Dialog>
        <Snackbar style={{top: 10, right: 10, bottom: 'none', left: 'none', zIndex: 10001, maxWidth: '100%', transition: 'transform 0ms cubic-bezier(0.23, 1, 0.32, 1) 0ms, visibility 0ms cubic-bezier(0.23, 2, 0.32, 1) 0ms'}}
                  bodyStyle={{margin: 0}} open={this.props.editor.errorMessenger.show}
                  message={this.props.editor.errorMessenger.msg} action={this.props.editor.errorMessenger.actionIcon}
                  autoHideDuration={5000}
                  onActionTouchTap={this.handleOnMessageTouch}
                  onRequestClose={this.handleErrorMessengerDismiss} />
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