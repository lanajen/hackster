import React, { Component } from 'react';
import { bindActionCreators } from 'redux';
import { connect } from 'react-redux';
import { Link } from 'react-router';

import * as AuthActions from '../actions/auth';
import * as UserActions from '../actions/user';

import ImportProject from '../components/ImportProject';

import Hero from '../components/Hero';

class Splash extends Component {
  constructor(props) {
    super(props);

    props.actions.getProjects();
  }

  componentWillMount() {
    if(!this.props.auth.authorized) {
      this.props.actions.authorizeUser(true);
    }
  }

  render() {
    const { auth, contest, vendors, user } = this.props;

    const boards = vendors.map((vendor, index) => {
      return (
        <div key={index} className="board-container">
          <div className="backdrop-container">
            <div className="backdrop">
              <img className="logo" src={vendor.logo_url}></img>
            </div>
          </div>
          <div className="board-img-container">
            <Link to={`/${vendor.user_name}`}>
              <img src={vendor.board_image_url} />
            </Link>
          </div>
          <div className="name">{vendor.board_name}</div>
        </div>
      );
    });

    const phases = contest.phases.map((phase, index, list) => {
      if(index === 2) return null;
      return (
        <div key={index} className="date-container">
          <div className="date-wrapper">

            <div className="date">{phase.date}</div>

            <div className="circle-container">
              <div className={index <= parseInt(contest.activePhase, 10) ? 'circle' : 'circle doughnut'}></div>
            </div>

            <div className="event-container">
              <div className="event">
                {phase.event}
                { phase.sub_event ? <div className="sub-action">{phase.sub_event}</div> : null }
              </div>
            </div>
          </div>
          {
            index != list.length-1
              ? <div className="line-wrapper">
                  <div className="line"></div>
                </div>
              : null
          }
        </div>
      );
    });

    return (
      <div>
        <Hero user={user} />
        <section id="description">
          <h2>The Competition</h2>

          <div className="description-columns">
            <p>Lorem ipsum dolor sit amet, consectetur adipisicing elit. Sapiente consequuntur ea itaque quas ipsum doloribus aliquam consectetur</p>
            <p>Lorem ipsum dolor sit amet, consectetur adipisicing elit. Autem doloribus ab expedita tempora perspiciatis porro odio possimus repellat hic impedit, esse modi facilis aperiam veniam provident reprehenderit eaque! Eligendi, quibusdam!</p>
          </div>

          <div className="boards">
            {boards}
          </div>
        </section>

        <section id="timeline">
          <div className="description">
            <h2>Timeline</h2>
            <p>Lorem ipsum dolor sit amet, consectetur adipisicing elit. Sapiente consequuntur ea itaque quas ipsum doloribus aliquam consectetur</p>
          </div>
          <div className="dates">
            {phases}
          </div>
        </section>
        <ImportProject userData={user} selectProject={actions.selectProject} submitProject={actions.submitProject}/>
      </div>
    );
  }
}

function mapStateToProps(state) {
  return {
    auth: state.auth,
    contest: state.contest,
    vendors: state.vendors,
    user: state.user
  };
}

function mapDispatchToProps(dispatch) {
  return { actions: bindActionCreators({ ...AuthActions, ...UserActions }, dispatch) };
}

export default connect(mapStateToProps, mapDispatchToProps)(Splash);