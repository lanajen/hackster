import React, { Component } from 'react';
import Dialog from './components/Dialog';
import GetIframe from './components/EmbedCodeDisplay';


export default class EmbedDialog extends Component {

  constructor(props) {
    super(props);

    this.state={
      open: false
    }
  }

  render() {
    return (
      <div>
        <Dialog dismissDialog={() => this.setState({open: false})} open={this.state.open}>
          <p>Copy and paste this code into your HTML!</p>
          <GetIframe iframeURL={this.props.iframeURL}/>
        </Dialog>
        <button onClick={() => this.setState({open: true})}>Get the Code!</button>
      </div>
    )
  }

}

