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

  onContentEditableChange(html) {
    this.props.actions.setHTML(html);
  },

  render() {
    let buttonIcon = this.props.editor.isEditable ? 'fa fa-edit btn' : 'fa fa-pencil btn';
    let buttonColor = this.props.editor.isEditable ? '#80CBC4' : '#4DD0E1';

    return (
      <div className="react-editor-wrapper">
        <div className="react-editor-toolbar-container">
          <Toolbar />
        </div>
        <Editable className="box" refLink={createRandomNumber()} />
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