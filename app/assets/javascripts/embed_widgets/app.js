import React, { Component } from 'react';
import Dialog from './components/Dialog';
import EmbedCode from './components/EmbedCode';

//fetching iframe image inside dialog is slow..?


export default class EmbedWidget extends Component {

  constructor(props) {
    super(props);

    this.state={ open: false }
  }

  render() {
    console.log(this.props.iframeURL)
    return (
      <div>
        <Dialog dismissDialog={() => this.setState({ open: false })} open={this.state.open}>
          <p>Copy and paste this code into your HTML!</p>
          <EmbedCode iframeURL={this.props.iframeURL}/>
        </Dialog>
        <button onClick={() => this.setState({ open: true })}>Get the Code!</button>
      </div>
    )
  }

}

