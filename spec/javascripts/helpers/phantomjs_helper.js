import React from 'react/addons';
import chai, { expect } from 'chai';
import sinon from 'sinon';
import sinonChai from 'sinon-chai';
import util from 'util';

chai.use(sinonChai);

const TestUtils = React.addons.TestUtils;

function createShallow(element, props) {
  let renderer = TestUtils.createRenderer();
  renderer.render(React.createElement(element, props));
  let output = renderer.getRenderOutput();

  return {
    props,
    output,
    renderer
  };
}

export default {
  React,
  expect,
  sinon,
  util,
  TestUtils,
  createShallow
};