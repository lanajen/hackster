import React, {Component, PropTypes} from 'react';
import ReactDOM from 'react-dom';

export default class ProgressBar extends Component {
  constructor(props) {
    super(props);

    this.state = { width: 0 };
  }

  componentDidMount() {
    let slider = ReactDOM.findDOMNode(this.refs.slider);

    this.timer = setInterval(() => {
      if(this.state.width >= 100) {
        clearInterval(this.timer);
      } else {
        this.setState({ width: this.state.width + 10 });
      }
    }, 100);
  }

  componentWillUnmount() {
    clearInterval(this.timer);
  }

  render() {
    let { rootName } = this.props;
    return (
      <div style={{ display: 'inline-block', width: 350, height: 28, backgroundColor: '#f0f0f0', borderRadius: 4, textAlign: 'center', verticalAlign: 'middle' }}>
        <span ref="slider"
              className="progress-bar progress-bar-success progress-bar-striped"
              style={ Object.assign(
                {},
                { transition: 'width 1s', display: 'block', height: '100%', padding: 5, color: '#444', borderRadius: 4 },
                { width: `${this.state.width}%` }
              )}>
          Uploading
        </span>
      </div>
    );
  }
}

ProgressBar.PropTypes = {

};