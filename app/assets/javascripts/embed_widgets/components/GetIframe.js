import React, { Component } from 'react';

let styles = {
  'width' : '100%',
  'height': '100px',
  'backgroundColor': 'blue'
}

let inputStyles = {
  'width' : '300px'
}



const GetIframe = ({
  userId
}) => {
  let url = 'http://www.localhost.local:5000/'+ userId + '/embed';

  return (
    <div style={styles}>
      <input style={inputStyles} type="text"
        value={"<iframe frameBorder='0' height='270' scrolling='no' src=" + url + " width='360'></iframe>"}
      />
    </div>
  )
}

export default GetIframe;