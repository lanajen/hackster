import React, { PropTypes } from 'react';
import ReactCSSTransitionGroup from 'react-addons-css-transition-group';

const Dialog = (initialProps) => {

  let { actions,
        actionsContainerStyle,
        bodyClassName,
        bodyStyle,
        className,
        dismissStyle,
        enableCloseButton,
        overlayClassName,
        overlayStyle,
        style,
        title,
        wrapperClassName,
        wrapperStyle,
      } = initialProps;

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
    overflow: 'auto',
    ...style
  }

  props.overlayStyle = {
    boxSizing: 'border-box',
    position: 'relative',
    width: '800',
    margin: '0 auto 40px',
    zIndex: 1050,
    maxWidth: '90%',
    opacity: 1,
    WebkitTransform: 'translateY(-50%)',
    msTransform: 'translateY(-50%)',
    transform: 'translateY(-50%)',
    animation: 'fade-up 450ms cubic-bezier(0.23, 1, 0.32, 1)',
    ...overlayStyle
  }

  props.wrapperStyle = {
    backgroundColor: '#ffffff',
    WebkitTransition: 'all 450ms cubic-bezier(0.23, 1, 0.32, 1) 0ms',
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
    WebkitTransform: 'translateZ(0px)',
    msTransform: 'translateZ(0px)',
    transform: 'translateZ(0px)',
    WebkitTransition: 'left 0ms cubic-bezier(0.23, 1, 0.32, 1) 0ms, opacity 400ms cubic-bezier(0.23, 1, 0.32, 1) 0ms',
    transition: 'left 0ms cubic-bezier(0.23, 1, 0.32, 1) 0ms, opacity 400ms cubic-bezier(0.23, 1, 0.32, 1) 0ms',
    zIndex: 200,
    backgroundColor: 'rgba(0, 0, 0, 0.541176)',
    overflow: 'auto'
  }

  props.dismissStyle = {
    fontSize: '45px',
    position: 'absolute',
    top: 0,
    right: '8px',
    outline: 0,
    fontWeight: 'normal'
  }

  props.titleStyle = {
    textAlign: 'center',
    lineHeight: 1,
    margin: '0 0 20px'
  }

  props.title = title && typeof title === 'object'
              ? title
              : title && typeof title === 'string'
              ? _buildTitle(title, props.titleStyle)
              : null;

  props.actions = actions && Array.isArray(actions)
                ? _buildActions(actions, actionsContainerStyle)
                : null;

  let dialog = initialProps.open
             ? _build(props)
             : (<div></div>);

  return dialog;

  function _build(props) {
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
            {enableCloseButton ? <button className='close' style={dismissStyle} onClick={initialProps.dismissDialog}>×</button> : null}
            {title}
            <div className={bodyClassName || null} style={bodyStyle}>
              {initialProps.children}
            </div>
            <div className="actions-wrapper">{actions}</div>
          </div>
        </div>
        <div style={maskStyle} onClick={initialProps.dismissDialog}></div>
      </div>
    );
  }

  function _buildTitle(title, titleStyle) {
    return (
      <div>
        <h4 style={titleStyle}>{title}</h4>
      </div>
    );
  }

  function _buildActions(actions, style) {
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

Dialog.propTypes = {
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

export default Dialog;
