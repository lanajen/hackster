import React, { Component } from 'react'
import Dialog from './Dialog'
import GetIframe from './GetIframe'

let infoStyles = {
  'width': '300px',
  'height': '200px'
}

export default class Info extends Component {

  constructor() {
    super()

    this.state = {
      open: false
    }
  }

  toggleOpen(){
    console.log('should be toggling')
    let toggle = !this.state.open;

    this.setState({
      open: toggle
    })
  }


  render() {
    return (
      <div style={infoStyles}>
        <h4>Hackster Badge</h4>
        <Dialog dismissDialog={() => this.toggleOpen()} open={this.state.open}>
          <GetIframe/>
        </Dialog>
        <button onClick={() => this.toggleOpen()}>Get the Code!</button>
      </div>
    )
  }
}
