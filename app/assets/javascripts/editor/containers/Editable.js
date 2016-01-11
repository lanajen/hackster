import { bindActionCreators } from 'redux';
import { connect } from 'react-redux';
import Editable from '../components/Editable';
import * as ToolbarActions from '../actions/toolbar';
import * as EditorActions from '../actions/editor';
import * as HistoryActions from '../actions/history';

function mapStateToProps(state) {
  return {
    editor: state.editor,
    toolbar: state.toolbar,
    history: state.history
  };
}

function mapDispatchToProps(dispatch) {
  return { actions: bindActionCreators(Object.assign({}, ToolbarActions, EditorActions, HistoryActions), dispatch) };
}

export default connect(mapStateToProps, mapDispatchToProps)(Editable);