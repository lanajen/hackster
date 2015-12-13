import React from 'react';
import { IconButton } from 'material-ui';

const Placeholder = React.createClass({

  getInitialState() {
    return {
      show: false
    };
  },

  handleMouseOver() {
    this.setState({
      show: true
    });
  },

  handleMouseLeave() {
    this.setState({
      show: false
    });
  },

  handleClick() {
    this.props.insertCE(this.props.storeIndex);
  },

  render() {
    let iconButton = this.state.show
                   ? (<IconButton style={{zIndex: 1000}} iconStyle={{color: 'lightblue'}} iconClassName="fa fa-plus-circle" tooltip="Click to insert text" onClick={this.handleClick} />)
                   : (null);

    return (
      <div data-hash={this.props.hash}
           className="react-editor-placeholder"
           onMouseOver={this.handleMouseOver}
           onMouseLeave={this.handleMouseLeave}
           onClick={this.handleClick}>
        {iconButton}
      </div>
    );
  }

});

export default Placeholder;