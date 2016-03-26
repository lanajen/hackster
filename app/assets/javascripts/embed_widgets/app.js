import React, { Component } from 'react'
import Badge from './components/Badge'
import Info from './components/Info'


let styles = {
  'width': '100%',
  'height': '500px',
  'display' : 'flex',
  'flexDirection': 'row',
  'justifyContent' : 'center',
  'backgroundColor': 'white',
  'border' : '1px solid #E5E5E5',
  'padding' : '5px'
}



export default class App extends Component {

  constructor(props) {
    super(props)

    this.state = {
      username: this.props.username,
      projectCount: this.props.projectCount,
      logo: this.props.logo
    }
  }

  render() {
    return (
      <div style={styles}>
        <Info/>
        <Badge logo={this.state.logo}/>
      </div>
    )
  }

}

