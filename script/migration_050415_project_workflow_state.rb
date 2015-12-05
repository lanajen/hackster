Project.where(approved: nil).publyc.update_all(workflow_state: :pending_review)
Project.where(approved: nil).pryvate.update_all(workflow_state: :unpublished)
Project.where(approved: true).update_all(workflow_state: :approved)
Project.where(approved: false).update_all(workflow_state: :rejected)