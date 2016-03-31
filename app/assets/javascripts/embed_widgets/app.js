import React, { Component } from 'react';
import Badge from './components/Badge';
import Info from './components/Info';


let styles = {
  'width': '80%',
  'height': '500px',
  'margin': '0 auto',
  'display' : 'flex',
  'flexDirection': 'row',
  'justifyContent' : 'space-between',
  'backgroundColor': 'white',
  'border' : '1px solid #E5E5E5',
  'padding' : '5px'
};



const App = ({
  username,
  projectCount,
  followers,
  respects,
  userId
}) => {
  let url = 'http://www.localhost.local:5000/'+ userId + '/embed';

  return (
    <div style={styles}>
      <Info userId={userId}/>
      <iframe frameBorder='0' height='180' width='400' scrolling='no' src={url}></iframe>
    </div>
  )

};

export default App;
