import React from 'react';
import Editor from './components/Editor';
import { createRedux } from 'redux';
import { Provider } from 'redux/react';
import * as stores from './stores/index';
import { bindActionCreators } from 'redux';
import { Connector } from 'redux/react';
import * as EditorActions from './actions/EditorActions';

const redux = createRedux(stores);

var App = React.createClass({

  render: function() {
    return (
      <Provider redux={redux}>
        { () =>
          <Connector select={(state) => {
            return {
              editor: state.editor
            }; 
          }}>
            {({editor, dispatch}) => 
              <Editor editor={editor} {...this.props} {...bindActionCreators(EditorActions, dispatch)} />
            }
          </Connector>
        }
      </Provider>
    );
  }

});

module.exports = App;