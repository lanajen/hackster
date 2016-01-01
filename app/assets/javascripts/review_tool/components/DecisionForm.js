import React from 'react';
import ReactDOM from 'react-dom';
import TextArea from './TextArea';

const DecisionForm = React.createClass({
  getInitialState: function() {
    return {
      decision: null,
      errors: {},
      isDisabled: false
    };
  },

  componentWillReceiveProps: function(nextProps) {
    if (typeof(nextProps.formState.isDisabled) != 'undefined') {
      this.setState({
        isDisabled: nextProps.formState.isDisabled
      })
    }
  },

  handleDecisionChange: function(e) {
    this.setState({
      decision: ReactDOM.findDOMNode(e.target).value,
      errors: {}
    });
  },

  handleSubmit: function(e) {
    e.preventDefault();
    this.setState({ isDisabled: true });
    let data = this.getFormData();

    if (this.isValid(data)) {
      this.props.onSubmit(data);
    } else {
      this.setState({ isDisabled: false });
      ReactDOM.findDOMNode(this.refs.button).blur();
    }
  },

  getFormData: function() {
    let data = {
      'decision': this.state.decision
    }

    if (this.refs.general)
      data['general'] = ReactDOM.findDOMNode(this.refs.general.refs.textarea).value;

    switch (this.state.decision) {
      case 'needs_work':
        Object.assign(data, {
          'type': ReactDOM.findDOMNode(this.refs.type.refs.textarea).value,
          'content_type': ReactDOM.findDOMNode(this.refs.content_type.refs.textarea).value,
          'name': ReactDOM.findDOMNode(this.refs.name.refs.textarea).value,
          'one_liner': ReactDOM.findDOMNode(this.refs.one_liner.refs.textarea).value,
          'cover_image_id': ReactDOM.findDOMNode(this.refs.cover_image_id.refs.textarea).value,
          'difficulty': ReactDOM.findDOMNode(this.refs.difficulty.refs.textarea).value,
          'product_tags_string': ReactDOM.findDOMNode(this.refs.product_tags_string.refs.textarea).value,
          'team': ReactDOM.findDOMNode(this.refs.team.refs.textarea).value,
          'communities': ReactDOM.findDOMNode(this.refs.communities.refs.textarea).value,
          'story_json': ReactDOM.findDOMNode(this.refs.story_json.refs.textarea).value,
          'hardware_parts': ReactDOM.findDOMNode(this.refs.hardware_parts.refs.textarea).value,
          'tool_parts': ReactDOM.findDOMNode(this.refs.tool_parts.refs.textarea).value,
          'schematics': ReactDOM.findDOMNode(this.refs.schematics.refs.textarea).value,
          'cad': ReactDOM.findDOMNode(this.refs.cad.refs.textarea).value,
          'code': ReactDOM.findDOMNode(this.refs.code.refs.textarea).value,
          'software_parts': ReactDOM.findDOMNode(this.refs.software_parts.refs.textarea).value
        });
        break;

      case 'approve':
        Object.assign(data, {
          'no_changes_needed': ReactDOM.findDOMNode(this.refs.no_changes_needed).checked
        });
        break;

      case 'reject':
        Object.assign(data, {
          'rejection_reason': ReactDOM.findDOMNode(this.refs.rejection_reason).value
        });
        break;
    }

    return data;
  },

  isValid: function(data) {
    let errors = {};

    switch (this.state.decision) {
      case 'needs_work':
        // TODO: check that *some* field has been entered
        break;

      case 'approve':
        if (!data.no_changes_needed)
          errors['no_changes_needed'] = "Please confirm that no changes are needed";
        break;

      case 'reject':
        if (data.rejection_reason === '')
          errors['rejection_reason'] = "Please select a reason to reject";
        break;

      default:
        errors['decision'] = 'Please select a decision';
    }

    this.setState({
      errors: errors
    })

    let isValid = true;
    for (let error in errors) {
      isValid = false;
      break;
    }

    return isValid;
  },

  render: function() {
    return (
      <div className="review-item review-item-decision">
        <div className="review-item-body">
          <form ref="form" onSubmit={this.handleSubmit}>
            {this.renderDecisionRadios()}
            {this.renderInputs()}
            {this.renderGeneralComment()}

            <input type="submit" name="commit" value="Send feedback" ref="button" className="btn btn-primary" disabled={this.state.isDisabled} />
          </form>
        </div>
      </div>
    );
  },

  renderField: function(label, id, field) {
    let classes = ['form-group'];
    if (id in this.state.errors)
      classes.push('has-error');
    classes = classes.join(' ');

    return (
      <div className={classes}>
        <label className="control-label" htmlFor={id}>{label}</label>
        {field}
        {this.renderErrorHelp(this.state.errors[id])}
      </div>
    );
  },

  renderDecisionRadios: function() {
    let classes = ['form-group'];
    if ('decision' in this.state.errors)
      classes.push('has-error');
    classes = classes.join(' ');

    return (
      <div className={classes}>
        <label className="control-label">Decision</label>
        {this.renderDecisionRadio('Give feedback', 'needs_work')}
        {this.renderDecisionRadio('Approve', 'approve')}
        {this.renderDecisionRadio('Reject', 'reject')}
        {this.renderErrorHelp(this.state.errors['decision'])}
      </div>
    );
  },

  renderDecisionRadio: function(label, value) {
    return (
      <div className="radio">
        <label>
          <input type="radio" value={value} name="decision" onChange={this.handleDecisionChange} /> {label}
        </label>
      </div>
    );
  },

  renderGeneralComment: function() {
    if (!this.state.decision) return;

    return this.renderTextArea('General comment', 'general');
  },

  renderInputs: function() {
    switch (this.state.decision) {
      case 'needs_work':
        return this.renderFeedbackInputs();
      case 'approve':
        return this.renderApproveInputs();
      case 'reject':
        return this.renderRejectInputs();
    }
  },

  renderFeedbackInputs: function() {
    return (
      <div>
        {this.renderTextArea('Template', 'type')}
        {this.renderTextArea('Content type', 'content_type')}
        {this.renderTextArea('Name', 'name')}
        {this.renderTextArea('Pitch', 'one_liner')}
        {this.renderTextArea('Cover image', 'cover_image_id')}
        {this.renderTextArea('Skill level', 'difficulty')}
        {this.renderTextArea('Tags', 'product_tags_string')}
        {this.renderTextArea('Team', 'team')}
        {this.renderTextArea('Communities', 'communities')}
        {this.renderTextArea('Story', 'story_json')}
        {this.renderTextArea('Components', 'hardware_parts')}
        {this.renderTextArea('Tools', 'tool_parts')}
        {this.renderTextArea('Schematics', 'schematics')}
        {this.renderTextArea('CAD', 'cad')}
        {this.renderTextArea('Code', 'code')}
        {this.renderTextArea('Apps and online services', 'software_parts')}
      </div>
    );
  },

  renderTextArea: function(label, id) {
    return (
      <TextArea label={label} id={id} ref={id} />
    );
  },

  renderApproveInputs: function() {
    let classes = ['form-group'];
    if ('no_changes_needed' in this.state.errors)
      classes.push('has-error');
    classes = classes.join(' ');

    return (
      <div className={classes}>
        <label className="checkbox">
          <input className="boolean" type="checkbox" ref="no_changes_needed" />
          No changes needed
        </label>
        {this.renderErrorHelp(this.state.errors['no_changes_needed'])}
      </div>
    );
  },

  renderErrorHelp: function(text) {
    if (text === '' || text === undefined) return;

    return (
      <p className="help-block">{text}</p>
    );
  },

  renderRejectInputs: function() {
    return this.renderField('Rejection reason', 'rejection_reason',
      <select className="form-control" ref="rejection_reason" id="rejection_reason">
        <option></option>
        <option value="ad_spam">Ad or spam</option>
        <option value="commercial">Commercial</option>
        <option value="not_hardware">Not hardware</option>
        <option value="other">Other</option>
      </select>
    );
  }
});

export default DecisionForm;