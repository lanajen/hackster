import React, { Component } from 'react';

let styles = {
  'width': '100%',
  'height': '100%',
  'display': 'block',
  'marginBottom': '10px'
};

let inputStyles = {
  'width' : '100%',
  'marginBottom': '10px'
};

const GetIframe = ({
  iframeURL
}) => {

  return (
    <div style={styles}>
      <input style={inputStyles} type="text"
        value={"<iframe frameBorder='0' height='270' scrolling='no' src=" + iframeURL + " width='360'></iframe>"}
      />
      <iframe frameBorder='0' height='270' scrolling='no' src={iframeURL} width='360'></iframe>
    </div>
  )
}

export default GetIframe;