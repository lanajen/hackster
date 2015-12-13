import { bindActionCreators } from 'redux';
import { connect } from 'react-redux';
import Toolbar from '../components/Toolbar';
import * as ToolbarActions from '../actions/toolbar';
import * as EditorActions from '../actions/editor';

function mapStateToProps(state) {
  return {
    editor: state.editor,
    toolbar: state.toolbar
  };
}

function mapDispatchToProps(dispatch) {
  return { actions: bindActionCreators(Object.assign({}, ToolbarActions, EditorActions), dispatch) };
}

export default connect(mapStateToProps, mapDispatchToProps)(Toolbar);