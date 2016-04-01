import React, { Component } from 'react';
import Dialog from './Dialog';
import GetIframe from './GetIframe';

let infoStyles = {
  'width': '500px',
  'height': '200px',
  'display': 'flex',
  'flexDirection': 'column',
  'justifyContent': 'space-around'
}

const Info = ({
  openDialog,
  closeDialog,
  dialogState,
  iframeURL
}) => {

    return (
      <div style={infoStyles}>
        <strong>Hackster Badge</strong>
        <p>Embed this badge on your page to display your some basic information about your Hackster profile, and to link your readers to your Hackster Page!</p>
        <Dialog dismissDialog={closeDialog} open={dialogState}>
          <p>Copy and paste this code into your HTML!</p>
          <GetIframe iframeURL={iframeURL}/>
        </Dialog>
      </div>
    )
}


export default Info