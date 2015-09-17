import React from 'react';
import Root from './containers/Root';

export default function() {
  React.render(
    <Root />, 
    document.getElementById('react-editor-main-mount')
  );
};