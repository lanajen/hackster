import React, { Component } from 'react'

let styles = {
  'width' : '100%',
  'height': '100px',
  'backgroundColor': 'blue'
}

let inputStyles = {
  'width' : '300px'
}
const GetIframe = () => {
  //generate the iframe code
  return (
    <div style={styles}>
      <input style={inputStyles} type="text" value='<iframe src="hackster.io/vanleuvenze">'/>
    </div>
  )
}

export default GetIframe