import React, { Component } from 'react';
import { bindActionCreators } from 'redux';
import { connect } from 'react-redux';

import * as AuthActions from '../actions/auth';
import * as UserActions from '../actions/user';

import ImportProject from '../components/ImportProject';

import Hero from '../components/Hero';

class Splash extends Component {
  constructor(props) {
    super(props);

    props.actions.getProjects();
    console.log(props)
  }

  componentWillMount() {
    if(!this.props.auth.authorized) {
      this.props.actions.authorizeUser(true);
    }
  }

  render() {
    const { auth, contest, vendors } = this.props;

    const boards = vendors.map((vendor, index) => {
      return (
        <div key={index} className="board-container">
          <div className="backdrop-container">
            <div className="backdrop">
              <span className="logo"></span>
            </div>
          </div>
          <div className="board-img-container">
            <a href="javascript:void(0);">
              <img src={index % 2 === 0 ? 'assets/mouser/chipkit.png' : 'assets/mouser/board-sample.png'} alt=""/>
            </a>
          </div>
          <div className="name">{vendor}</div>
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
        <Hero />
        <section id="vendors">
          <div className="title">The Competition</div>

          <div className="description-columns">
            <div className="description">
              <span className="bullet">•</span>
              <span className="brief">
                Lorem ipsum dolor sit amet, consectetur adipisicing elit. Sapiente consequuntur ea itaque quas ipsum doloribus aliquam consectetur
              </span>
            </div>
            <div className="description">
              <span className="bullet">•</span>
              <span className="brief">
                Lorem ipsum dolor sit amet, consectetur adipisicing elit. Sapiente consequuntur ea itaque quas ipsum doloribus aliquam consectetur
              </span>
            </div>
          </div>

          <div className="boards">
            {boards}
          </div>

          <div className="timeline" id="timeline">
            <div className="description">
              <h3>TIMELINE</h3>
              <p>Lorem ipsum dolor sit amet, consectetur adipisicing elit. Sapiente consequuntur ea itaque quas ipsum doloribus aliquam consectetur</p>
            </div>
            <div className="dates">
              {phases}
            </div>
          </div>
        </section>
      </div>
    );
  }
}


function mapStateToProps(state) {
  return {
    auth: state.auth,
    contest: state.contest,
    vendors: state.vendors
  };
}

function mapDispatchToProps(dispatch) {
  return { actions: bindActionCreators({ ...AuthActions, ...UserActions }, dispatch) };
}

export default connect(mapStateToProps, mapDispatchToProps)(Splash);