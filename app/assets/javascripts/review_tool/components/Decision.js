import React from 'react';
import ItemHeader from './ItemHeader';

const Decision = React.createClass({
  render: function() {
    return (
      <div className=''>
        <ItemHeader action='left a review' {...this.props} />
        <div className='review-item-body'>
          {this.renderDecision()}
          {this.renderComment(this.props.feedback.general, 'General comment')}
        </div>
      </div>
    );
  },

  renderDecision: function() {
    switch (this.props.decision) {
      case 'needs_work':
        return this.renderNeedsWork();
      case 'approve':
        return this.renderApproved();
      case 'reject':
        return this.renderRejected();
    }
  },

  renderNeedsWork: function() {
    const { feedback } = this.props;

    return (
      <div>
        {this.renderWithLabel((
          <span>
            <i className='fa fa-exclamation-triangle text-warning'></i><span>Needs work</span>
          </span>), 'Decision')}
        {this.renderComment(feedback.type, 'Template')}
        {this.renderComment(feedback.content_type, 'Content type')}
        {this.renderComment(feedback.name, 'Name')}
        {this.renderComment(feedback.one_liner, 'Elevator pitch')}
        {this.renderComment(feedback.cover_image_id, 'Cover image')}
        {this.renderComment(feedback.difficulty, 'Skill level')}
        {this.renderComment(feedback.product_tags_string, 'Tags')}
        {this.renderComment(feedback.team, 'Team')}
        {this.renderComment(feedback.communities, 'Communities')}
        {this.renderComment(feedback.story_json, 'Story')}
        {this.renderComment(feedback.hardware_parts, 'Components')}
        {this.renderComment(feedback.tool_parts, 'Tools')}
        {this.renderComment(feedback.schematics, 'Schematics')}
        {this.renderComment(feedback.cad, 'CAD')}
        {this.renderComment(feedback.code, 'Code')}
        {this.renderComment(feedback.software_parts, 'Apps and online services')}
      </div>
    );
  },

  renderApproved: function() {
    return this.renderWithLabel((
      <span>
        <i className='fa fa-check text-success'></i><span>Approved</span>
      </span>), 'Decision');
  },

  renderRejected: function() {
    return (
      <div>
        {this.renderWithLabel((
          <span>
            <i className='fa fa-times text-danger'></i><span>Rejected</span>
          </span>), 'Decision')}
        {this.renderWithLabel(this.props.rejection_reason, 'Reason')}
      </div>
    );
  },

  renderComment: function(comment, label) {
    if (!comment) return;

    let commentHtml = comment.replace(/\n/g, '<br>');

    return this.renderWithLabel((<span dangerouslySetInnerHTML={{ __html: commentHtml }} />), label);
  },

  renderWithLabel: function(element, label) {
    if (!element) return;

    return (
      <p>
        <strong>{label}:</strong> {element}
      </p>
    );
  }
});

export default Decision;