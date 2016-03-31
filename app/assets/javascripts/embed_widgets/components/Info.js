import React, { Component } from 'react';
import Dialog from './Dialog';
import GetIframe from './GetIframe';

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

  render() {
    const actions = [<button className='btn btn-primary'>Cancel</button>, <button className='btn btn-primary'>Submit</button>];
    return (
      <div style={infoStyles}>
        <h4>Hackster Badge</h4>
        <Dialog actions={actions} dismissDialog={() => this.setState({open: false})} open={this.state.open}>
          <GetIframe userId={this.props.userId}/>
        </Dialog>
        <button onClick={() => this.setState({open: true})}>Get the Code!</button>
      </div>
    )
  }
}
