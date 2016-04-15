import React, { PropTypes } from 'react'
import Select from 'react-select'
import { connect } from 'react-redux'

const ImportProject = ({ userData, selectProject, submitProject }) => {

  return (
    <div>
      <Select
        name='Import your project from Hackster!'
        options={userData.projects}
        onChange={selectProject} />
      {
        userData.submission && userData.submission.label
          ? (<div>
              {userData.submission.label}
              <br/>
              <button onClick={submitProject}>submit!</button>
            </div>)
          : null
      }
    </div>
  )
}

ImportProject.PropTypes = {
  userData: PropTypes.object.isRequired,
  selectProject: PropTypes.func.isRequired,
  submitProject: PropTypes.func.isRequired
}

export default ImportProject;