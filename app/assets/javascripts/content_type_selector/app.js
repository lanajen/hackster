import React, {Component, PropTypes} from 'react';

const ALLOWED_CONTENT_TYPES = ['tutorial', 'showcase', 'wip', 'protip', 'getting_started', 'teardown'];

export default class App extends Component {
  constructor(props) {
    super(props);
    this.handleChange = this.handleChange.bind(this);

    this.state = this.computeState(this.props.initialContentType, this.props.initialHasError);
  }

  computeState(contentType, hasError){
    let isProtip = contentType ? ['protip', 'getting_started', 'teardown'].indexOf(contentType) > -1 : null;
    let isWip = isProtip !== false || contentType == 'select_wip' ? null : contentType == 'wip';
    let isTutorial = isWip !== false || contentType == 'select_tutorial' ? null : contentType == 'tutorial';

    return {
      contentType: (ALLOWED_CONTENT_TYPES.indexOf(contentType) > -1 ? contentType : null),
      hasError: hasError,
      isProtip: isProtip,
      isWip: isWip,
      isTutorial: isTutorial
    };
  }

  handleChange(e) {
    let states = this.computeState(e.target.value, false);
    this.setState(states);
  }

  _renderProjectType() {
    let classes = ['form-group'];
    let errorMsg = null;
    if (this.state.hasError && this.state.isProtip === null) {
      classes.push('has-error');
      errorMsg = (<p className="help-block">is required for publication</p>);
    }

    return (
      <div className={classes.join(' ')}>
        <div className="col-md-4">
          <label className="control-label">Project type</label>
        </div>
        <div className="col-md-8">
          <div className="radio small">
            <label>
              <input type="radio" value="select_wip" checked={this.state.isProtip === false} onChange={this.handleChange} name="protip" />
              <div>
                <i className="fa fa-rocket"></i>
                <span>I am describing how I built a device</span>
              </div>
              <div className="small text-muted">
                Examples: a weather station, a smart thermostat
              </div>
            </label>
          </div>
          <div className="radio small">
            <label>
              <input type="radio" value="protip" checked={this.state.isProtip === true} onChange={this.handleChange} name="protip" />
              <div>
                <i className="fa fa-bullseye"></i>
                <span>I am describing how to solve a specific problem</span>
              </div>
              <div className="small text-muted">
                Examples: how to control a motor with Arduino Uno, get started with Raspberry Pi
              </div>
            </label>
          </div>
          {errorMsg}
        </div>
      </div>
    );
  }

  _renderProgress() {
    if (this.state.isProtip !== false)
      return;

    let classes = ['form-group'];
    let errorMsg = null;
    if (this.state.hasError && this.state.isWip === null) {
      classes.push('has-error');
      errorMsg = (<p className="help-block">is required for publication</p>);
    }

    return (
      <div className={classes.join(' ')}>
        <div className="col-md-4">
          <label className="control-label">Progress</label>
        </div>
        <div className="col-md-8">
          <div className="radio small">
            <label>
              <input type="radio" value="wip" name="wip" checked={this.state.isWip === true} onChange={this.handleChange} />
              <i className="fa fa-battery-half"></i>
              <span>I am still working on my project</span>
            </label>
          </div>
          <div className="radio small">
            <label>
              <input type="radio" value="select_tutorial" name="wip" checked={this.state.isWip === false} onChange={this.handleChange} />
              <i className="fa fa-battery-full"></i>
              <span>My project is complete</span>
            </label>
          </div>
          {errorMsg}
        </div>
      </div>
    );
  }

  _renderInstructions() {
    if (this.state.isWip !== false)
      return;

    let classes = ['form-group'];
    let errorMsg = null;
    if (this.state.hasError && this.state.isTutorial === null) {
      classes.push('has-error');
      errorMsg = (<p className="help-block">is required for publication</p>);
    }

    return (
      <div className={classes.join(' ')}>
        <div className="col-md-4">
          <label className="control-label">Instructions</label>
        </div>
        <div className="col-md-8">
          <div className="radio small">
            <label>
              <input type="radio" value="tutorial" name="instructions" checked={this.state.isTutorial === true} onChange={this.handleChange} />
              <i className="fa fa-book"></i>
              <span>My project provides full instructions</span>
            </label>
          </div>
          <div className="radio small">
            <label>
              <input type="radio" value="showcase" name="instructions" checked={this.state.isTutorial === false} onChange={this.handleChange} />
              <i className="fa fa-file-image-o"></i>
              <span>My project provides no or partial instructions</span>
            </label>
          </div>
          {errorMsg}
        </div>
      </div>
    );
  }

  render() {
    return (
      <div>
        {this._renderProjectType()}
        {this._renderProgress()}
        {this._renderInstructions()}
        <input type="hidden" value={this.state.contentType} name="base_article[content_type]" />
      </div>
    );
  }
}

App.PropTypes = {
  initialContentType: PropTypes.string.isRequired,
  initialHasError: PropTypes.bool.isRequired
};