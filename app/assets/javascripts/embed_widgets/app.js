import React, { Component } from 'react';
import Info from './components/Info';


let styles = {
  'width': '1000px',
  'height': '80vh',
  'margin': '0 auto',
  'backgroundColor': 'white',
  'border' : '1px solid #E5E5E5',
  'padding' : '5px'
};

let infoWrapperStyles = {
  'width': '100%',
  'height': '300px',
  'display' : 'flex',
  'flexDirection': 'row',
  'borderBottom': '1px solid #E5E5E5'
};

let embedInfoStyles = {
  'display': 'flex',
  'flexDirection': 'column',
  'justifyContent': 'space-around'
};


export default class App extends Component {

  constructor(props) {
    super(props);

    this.state = {
      dialogOpen: false
    }

    this.openDialog = this.openDialog.bind(this);
    this.closeDialog = this.closeDialog.bind(this);
  }

  openDialog() {
    this.setState({dialogOpen: true});
  }

  closeDialog() {
    this.setState({dialogOpen: false});
  }


  render() {
    let iframeURL = 'http://www.localhost.local:5000/users/'+ this.props.userId + '/embed';
    return (
      <div style={styles}>
        <div style={infoWrapperStyles}>
          <Info iframeURL={iframeURL} dialogState={this.state.dialogOpen} openDialog={this.openDialog} closeDialog={this.closeDialog}/>
          <div style={embedInfoStyles}>
            <iframe frameBorder='0' height='180' width='400' scrolling='no' src={iframeURL}></iframe>
            <button onClick={this.openDialog}>Get the Code!</button>
          </div>
        </div>
      </div>
    )
  }

}

