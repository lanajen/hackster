class ProjectCollectionDecorator < ApplicationDecorator
  def status_css
    case model.workflow_state
    when 'approved', 'featured'
      'success'
    when 'pending_review'
      'warning'
    when 'rejected'
      'danger'
    else
      ''
    end
  end

  def status
    case model.workflow_state
    when 'approved'
      'Showing'
    when 'pending_review'
      'Pending review'
    when 'rejected'
      'Hidden'
    when 'featured'
      'Featured'
    else
      'Unknown'
    end
  end
end