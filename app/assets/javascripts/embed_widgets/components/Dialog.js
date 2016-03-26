import React, { Component, PropTypes } from 'react';
import ReactDOM from 'react-dom';

export default class Dialog extends Component {

  constructor(props) {
    super(props);

  }

  render() {
    let { actions,
          actionsContainerStyle,
          bodyClassName,
          bodyStyle,
          className,
          enableCloseButton,
          overlayClassName,
          overlayStyle,
          style,
          title,
          wrapperClassName,
          wrapperStyle,
        } = this.props;

    const props = {
      bodyClassName,
      className,
      enableCloseButton,
      overlayClassName,
      wrapperClassName,
    };

    /** Styles */

    props.style = {
      position: 'fixed',
      boxSizing: 'border-box',
      zIndex: '1000',
      top: 0,
      left: 0,
      width: '100%',
      height: '100%',
      transition: 'left 0ms cubic-bezier(0.23, 1, 0.32, 1) 0ms',
      overflow: 'auto',
      paddingTop: 16,
      textAlign: 'left',
      ...style
    }

    props.overlayStyle = {
      boxSizing: 'border-box',
      transition: 'all 450ms cubic-bezier(0.23, 1, 0.32, 1) 0ms',
      position: 'relative',
      width: '800',
      margin: '0 auto 40px',
      zIndex: 1050,
      maxWidth: '90%',
      opacity: 1,
      transform: 'translate3d(0px, 64px, 0px)',
      ...overlayStyle
    }

    props.wrapperStyle = {
      backgroundColor: '#ffffff',
      transition: 'all 450ms cubic-bezier(0.23, 1, 0.32, 1) 0ms',
      boxSizing: 'border-box',
      minHeight: 250,
      padding: '50px',
      ...wrapperStyle
    }

    props.bodyStyle = {
      ...bodyStyle
    }

    props.maskStyle = {
      position: 'fixed',
      height: '100%',
      width: '100%',
      top: 0,
      left: 0,
      opacity: 1,
      willChange: 'opacity',
      transform: 'translateZ(0px)',
      transition: 'left 0ms cubic-bezier(0.23, 1, 0.32, 1) 0ms, opacity 400ms cubic-bezier(0.23, 1, 0.32, 1) 0ms',
      zIndex: 200,
      backgroundColor: 'rgba(0, 0, 0, 0.541176)',
      overflow: 'auto'
    }

    props.maskStyle = {
      position: 'fixed',
      height: '100%',
      width: '100%',
      top: 0,
      left: 0,
      opacity: 1,
      willChange: 'opacity',
      transform: 'translateZ(0px)',
      transition: 'left 0ms cubic-bezier(0.23, 1, 0.32, 1) 0ms, opacity 400ms cubic-bezier(0.23, 1, 0.32, 1) 0ms',
      zIndex: 200,
      backgroundColor: 'rgba(0, 0, 0, 0.541176)',
      overflow: 'auto'
    }

    let dismissStyle = {
      fontSize: '45px',
      position: 'absolute',
      top: 0,
      right: '8px',
      outline: 0,
      fontWeight: 'normal'
    }

    props.title = title && typeof title === 'object'
                ? title
                : title && typeof title === 'string'
                ? this._buildTitle(title, dismissStyle)
                : null;

    props.actions = actions && Array.isArray(actions)
                  ? this._buildActions(actions, actionsContainerStyle)
                  : null;

    let dialog = this.props.open
               ? this._build(props)
               : (<div></div>);

    return dialog;
  }

  _build(props) {
    let { actions,
          bodyClassName,
          bodyStyle,
          className,
          dialogTitle,
          dismissStyle,
          enableCloseButton,
          maskStyle,
          overlayClassName,
          overlayStyle,
          style,
          title,
          wrapperClassName,
          wrapperStyle,
        } = props;


    return (
      <div className={className || null} style={style}>
        <div className={overlayClassName || null} style={overlayStyle}>
          <div className={wrapperClassName || null} style={wrapperStyle}>
            {enableCloseButton ? <button className='close' onClick={this.props.dismissDialog}>×</button> : null}
            {title}
            <div className={bodyClassName || null} style={bodyStyle}>
              {this.props.children}
            </div>
            <div className="actions-wrapper">
              {actions}
            </div>
          </div>
        </div>
        <div style={maskStyle} onClick={this.props.dismissDialog}></div>
      </div>
    );
  }

  _buildTitle(title, dismissStyle) {
    return (
      <div className="dialog-title-wrapper">
        <h4 className="dialog-title">{title}</h4>
      </div>
    );
  }

  _buildActions(actions, style) {
    const styles = {
      boxSizing: 'border-box',
      width: '100%',
      textAlign: 'right',
      marginTop: '20px',
      ...style
    };

    return (
      <div style={styles}>
        {React.Children.toArray(actions)}
      </div>
    );
  }
}

Dialog.PropTypes = {
  actions: PropTypes.array,
  actionsContainerStyle: PropTypes.object,
  bodyClassName: PropTypes.string,
  bodyStyle: PropTypes.object,
  className: PropTypes.string,
  dismissDialog: PropTypes.func.isRequired,
  enableCloseButton: PropTypes.bool,
  open: PropTypes.bool.isRequired,
  overlayClassName: PropTypes.string,
  overlayStyle: PropTypes.object,
  style: PropTypes.object,
  title: PropTypes.any,
  wrapperClassName: PropTypes.string,
  wrapperStyle: PropTypes.object,
};

Dialog.defaultProps = {
  enableCloseButton: true
};