import React, { Component } from 'react'


let embedBadgeStyles = {
  'width': '400px',
  'height': '180px',
  'display': 'flex',
  'flexDirection': 'row',
  'backgroundImage': 'url(../../../assets/home/banner-6c6ea6219103030f4b618aef7657b4bd.jpg)',
  'backgroundSize': '400px 180px',
  'border': '1px solid #E5E5E5'
}
let imgStyles = {
  'height': '80px',
  'width': '80px',
  'padding': '10px 0 0 10px',
  'marginRight': '5px'
}
let badgeInfoStyles = {
  'width': '320px',
  'height': '120px',
  'display': 'flex',
  'flexDirection' : 'column',
  'color' : 'white'
}
let infoListStyles = {
  'listStyleType': 'none',
  'display' : 'flex',
  'flexDirection' : 'row',
  'justifyContent' : 'space-between',
  'paddingLeft': '0px'
}

const Badge = ({
  username,
  projectCount,
  logo
}) => {

  /*
  we also want a follow button, and a hackster badge that links back to hackster
  */

  return (
    <div style={embedBadgeStyles}>
      <img style={imgStyles} src='../../../assets/hackster_logo_squared.png' alt='Hackster logo squared'/>
      <div style={badgeInfoStyles}>
        <h4><strong>Zack Dean</strong></h4>
        <ul style={infoListStyles}>
          <li>projects</li>
          <li>followers</li>
          <li>respect</li>
        </ul>
      </div>
    </div>
  )

}

export default Badge