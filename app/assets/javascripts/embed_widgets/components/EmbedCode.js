import React, { Component } from 'react';

const styles = {
  'width': '100%',
  'height': '100%',
  'display': 'block',
  'marginBottom': '10px'
};

const inputStyles = {
  'width' : '100%',
  'marginBottom': '10px'
};

const EmbedCode = ({
  iframeURL
}) => {
  console.log('this is from within embed code', iframeURL)
  let embedCodeValue = `<iframe frameBorder='0' height='270' scrolling='no' src=${iframeURL} width='360'></iframe>`;
  return (
    <div style={styles}>
      <input style={inputStyles} type="text" value={embedCodeValue}/>
      <iframe frameBorder='0' height='270' scrolling='no' src={iframeURL} width='360'></iframe>
    </div>
  )
}

export default EmbedCode;