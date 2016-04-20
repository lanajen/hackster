import React, { PropTypes } from 'react';
import Select from 'react-select';

const ImportProject = ({ userData, currentVendor, selectProject, submitProject }) => {
  let currentSelection = null;
  return (
    <div>
      <Select
        placeholder={'Import your project from Hackster!'}
        options={userData.projects}
        onChange={ (selection) => { currentSelection = selection } }/>
      <button onClick={() => submitProject(currentSelection, currentVendor)}>submit!</button>
    </div>
  )
}

ImportProject.PropTypes = {
  userData: PropTypes.object.isRequired,
  selectProject: PropTypes.func.isRequired,
  submitProject: PropTypes.func.isRequired
}

export default ImportProject;
