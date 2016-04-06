import React, { Component } from 'react'

//here we want to be rendering vendor information being passed via props

const Vendors = (props) => {
  console.log('Rendering....', props);

  const platformLogo = props.platformImage || "assets/mouser/vendor-logo.svg";
  const platformBoard = props.platformBoard || "assets/mouser/chipkit-uc-32-copy.png";
  const description = props.description || "Chip combines the ease-of-use of the classic boards with the latest technologies.  The board recognises gestures, and features a six-axis accelerometer and gyroscope.  Control your projects with your phone over Bluetooth connectivity!";
  const nextLinkImage = props.description || 'assets/mouser/board-sample.png';
  const prevLinkImage = props.description || 'assets/mouser/board-sample.png';
  const nextPlatform = props.description || 'BEAGLE BOARD';
  const prevPlatform = props.description || 'CHIP';

  return (
    <div id='vendor-details'>
      <div className='details-wrapper'>
        <div className='image-container'>
          <div className='image-wrap'>
            <img className='logo' src={platformLogo}/>
            <img className='board' src={platformBoard}/>
          </div>
        </div>
        <div className='description-container'>
          <div className='description'>
            <strong>Chip</strong>
            <p>{description}</p>
            <div className='buttons'>
              <div className='button'> VISIT SITE </div>
              <div className='button'> SHARE </div>
            </div>
          </div>
        </div>
      </div>
      <div className='vendor-links'>
        <div className='vendor-link-button'>
          <div className='link-container'>
            <div className='image'>
              <img src={prevLinkImage}/>
            </div>
            <div className='info'>
              <p> PREVIOUS </p>
              <div className='vendor-name'>{prevPlatform}</div>
            </div>
          </div>
        </div>
        <div className='vendor-link-button'>
          <div className='link-container'>
            <div className='image'>
              <img src={nextLinkImage}/>
            </div>
            <div className='info'>
              <p> NEXT </p>
              <div className='vendor-name'>{nextPlatform}</div>
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}

export default Vendors;