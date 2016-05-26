import React, {Component, PropTypes} from 'react';
import { generateCSV, getFileDetails } from './utils/Requests';
import ImageHelpers from '../utils/Images';

export default class App extends Component {
  constructor(props) {
    super(props);
    this.handleClick = this.handleClick.bind(this);

    this.state = { isWorking: null, fileId: null };
  }

  handleClick(e) {
    if (this.state.isWorking || this.state.fileUrl)
      return;

    e.preventDefault();
    this.setState({ isWorking: true });
    let fileId = null;

    return generateCSV(this.props.url)
      .then(response => {
        fileId = response.body.file_id;
        return ImageHelpers.pollJob(response.body.job_id);
      })
      .then(response => {
        return getFileDetails(fileId);
      })
      .then(response => {
        this.setState({ isWorking: false, fileUrl: response.body.file.url });
        if (window)
          window.location = this.state.fileUrl;
          return;
      })
      .catch(err => {
        this.setState({ isWorking: false });
        console.log('Remote Upload Error ', err);
      });
  }

  render() {
    let text = this.state.isWorking ?
              (<span>
                <i className="fa fa-spin fa-spinner" />
                <span>Preparing file...</span>
              </span>) :
              (<a href={this.state.fileUrl ? this.state.fileUrl : ''} onClick={this.handleClick}>
                {this.props.label}
              </a>);

    return (
      <span>
        {text}
      </span>
    );
  }
}

App.PropTypes = {
  label: PropTypes.string.isRequired,
  url: PropTypes.string.isRequired,
};