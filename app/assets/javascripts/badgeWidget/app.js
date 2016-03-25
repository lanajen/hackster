import React, { Component } from 'react'

const embedBadgeContainer = {
  'width': '100%',
  'height': '200px',
  'display' : 'flex',
  'justifyContent' : 'center',
  'backgroundColor': 'white',
  'border' : '1px solid #E5E5E5',
  'padding' : '5px'
}



export default class App extends Component {

  constructor(props) {
    super(props)

    console.log('these should be your props', this.props);

    this.state = {
      username: null,
      projectCount: null
    }
  }

  render() {
    return (
      <div style={embedBadgeContainer}>
      react on rails!
      </div>
    )
  }

}

