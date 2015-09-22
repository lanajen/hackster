import React from 'react/addons';
import { bindActionCreators } from 'redux';
import { connect } from 'react-redux';
import Toolbar from './Toolbar';
import Editable from './Editable';
import * as ToolbarActions from '../actions/toolbar';
import * as EditorActions from '../actions/editor';
import { createRandomNumber } from '../../utils/Helpers';
import injectTapEventPlugin from 'react-tap-event-plugin';
import mui from 'material-ui';

/** This can be removed when React1.0 is released. */
injectTapEventPlugin();

const PureRenderMixin = React.addons.PureRenderMixin;
const ThemeManager = new mui.Styles.ThemeManager();

const Editor = React.createClass({
  mixins: [PureRenderMixin],

  childContextTypes: {
    muiTheme: React.PropTypes.object
  },

  getChildContext() {
    return {
      muiTheme: ThemeManager.getCurrentTheme()
    };
  },

  render() {
    if(this.props.hashLocation !== '#story') {
      return null;
    }

    return (
      <div className="react-editor-wrapper">
        <div className="react-editor-toolbar-container">
          <Toolbar hashLocation={this.props.hashLocation} />
        </div>
        <Editable className="box" refLink={createRandomNumber()} hashLocation={this.props.hashLocation} />
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