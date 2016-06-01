import React, { Component } from 'react';
import ListsDropdown from './components/ListsDropdown';
import ListsStore from './stores/ListsStore';

export default class App extends Component {
  constructor(props) {
    super(props);

    this.state = {
      isDropdownOpen: false,
    };

    this.handleCloseDropdown = this.handleCloseDropdown.bind(this);
    this.handleListButtonClick = this.handleListButtonClick.bind(this);
  }

  componentDidMount() {
    if (window) {
      window.addEventListener('click', this.handleCloseDropdown);
    }
  }

  componentWillUnmount() {
    if (window) {
      window.removeEventListener('click', this.handleCloseDropdown);
    }
  }

  handleCloseDropdown(e) {

    if (!this.state.isDropdownOpen) { return; }

    return this._listDropdown.contains(e.target)
      ? null
      : this.setState({ isDropdownOpen: false });
  }

  handleListButtonClick() {
    this.setState({
      isDropdownOpen: !this.state.isDropdownOpen
    });

    if (!ListsStore.isPopulated) {
      ListsStore.populateStore(this.props.projectId);
    }
  }

  render() {

    let label = this.props.iconOnly === true ? null : (<span>Bookmark</span>);
    let btnClass = this.props.btnClass ? this.props.btnClass : 'btn-link';

    return (
      <div ref={(c) => this._listDropdown = c} className='lists-dropdown'>
        <a href="javascript:void(0)" className={`btn ${btnClass} btn-sm toggle-lists-btn`} onClick={this.handleListButtonClick} title={this.props.iconOnly === true ? "Bookmark" : null}>
          <i className="fa fa-bookmark-o"></i>
          {label}
        </a>
        <ListsDropdown isOpen={this.state.isDropdownOpen} {...this.props} />
      </div>
    );
  }
}