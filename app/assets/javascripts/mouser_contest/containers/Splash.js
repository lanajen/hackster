import React, { Component } from 'react';
import { bindActionCreators } from 'redux';
import { connect } from 'react-redux';

import * as AuthActions from '../actions/auth';

import Hero from '../components/Hero';

class Splash extends Component {
  constructor(props) {
    super(props);
  }

  // React router and connect will complain if we move this up into the constructor.
  componentWillMount() {
    if(!this.props.auth.authorized) {
      this.props.actions.authorizeUser(true);
    }
  }

  render() {
    const { auth, contest, platforms } = this.props;

    const boardList = platforms.map((platform, index) => {
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
          <div className="name">{platform}</div>
        </div>
      );
    });

    const dateChart = contest.phases.map((phase, index, list) => {
      return (
        <div key={index} className="date-container">
          <div className="date-wrapper">

            <div className="date">{phase.date}</div>

            <div className="circle-container">
              <div className={index === 0 ? 'circle' : 'circle doughnut'}></div>
            </div>

            <div className="event-container">
              <div className="event">
                {phase.event}
                { phase.sub_action ? <div className="sub-action">{phase.sub_action}</div> : null }
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
            {boardList}
          </div>

          <div className="timeline" id="timeline">
            <div className="description">
              <h3>TIMELINE</h3>
              <p>Lorem ipsum dolor sit amet, consectetur adipisicing elit. Sapiente consequuntur ea itaque quas ipsum doloribus aliquam consectetur</p>
            </div>
            <div className="dates">
              {dateChart}
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
    platforms: state.platforms
  };
}

function mapDispatchToProps(dispatch) {
  return { actions: bindActionCreators(AuthActions, dispatch) };
}

export default connect(mapStateToProps, mapDispatchToProps)(Splash);