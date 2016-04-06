<<<<<<< HEAD
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
||||||| merged common ancestors
=======
import React, { Component } from 'react'
import Select from 'react-select'
import { connect } from 'react-redux'



/*
This component should be a dropdown that allows the user to select
and import a project from their hackster account

-get all the current user's projects

-allow them to select and submit a project
  |_ This should trigger a post to an API route that will save the project
      to our db.
  |_ Create the model in rails / be able to fetch a signed in user's
      submitted projects



*/

class ImportProject extends Component {

  constructor() {
    super();

    // this.state = { userProjects: null, projectToSubmit: null };

    this.queueProjectForSubmission = this.queueProjectForSubmission.bind(this);
    this.submitProject = this.submitProject.bind(this);
  }

  componentWillMount() {



    //here we dispatch our async action

    console.log('CHECKING REDUX CONFIG', this.props.state);


  }

  queueProjectForSubmission(project) {

    this.props.dispatch({
      type: 'QUEUE_SUBMISSION',
      projectToSubmit: project
    });

  }

  submitProject() {

    //get the project id, description, and user_id
    let { id, authors, name } = this.props.projectToSubmit.value;

    //this is goint
    let payload = {
      userId: id,
      projectId: authors[0].id,
      description: name
    }

    console.log('about to submit this shit', payload, this.props.projectToSubmit);

    fetch('http://api.localhost.local:5000/v1/mouser_contest/submit', {
      method: 'post',
      mode: 'no-cors',
      body: JSON.stringify(payload),
      headers: new Headers({
        'Content-Type': 'application/json',
        'Accept': 'application/json'
      })
    })
    .catch(function (err) {
      console.log('WE HAVE A PROBLEM', err)
    })

  }


  render() {
    return (
      <div>
        <Select
          name='Import your project from Hackster!'
          options={this.props.userProjects}
          onChange={this.queueProjectForSubmission}
        />
        {
          this.props.projectToSubmit
            ? <div>{this.props.projectToSubmit.label} <br/> <button onClick={this.submitProject}>submit!</button> </div>
            : null
        }
      </div>
    )
  }
}

const mapStateToProps = (state) => ({
  ...state.projectSubmission,
  state: state
})



export default connect(mapStateToProps)(ImportProject);
>>>>>>> added an auth component for route authentication
