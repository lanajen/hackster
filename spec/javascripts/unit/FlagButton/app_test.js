import React from 'react';
import ReactDOM from 'react-dom';
import { Simulate, renderIntoDocument } from 'react-addons-test-utils';
import expect from 'expect';
import util from 'util';
import FlagButton from 'flag_button/app';

describe('Flag Button', () => {
  it('should set state "flagged" to true when flagContent is resolved', (done) => {
    FlagButton.__Rewire__('flagContent', () => Promise.resolve());

    function resetDep() {
      FlagButton.__ResetDependency__('flagContent');
    }

    const component = renderIntoDocument(<FlagButton currentUserId="0123" flaggable={{ id: 666, type: 'flag' }} />);

    return component.handleFlagButtonClick()
      .then(() => {
        const { flagged, isLoading} = component.state;

        expect(flagged).toBe(true);
        expect(isLoading).toBe(false);

        resetDep();
        done();
      })
      .catch(err => {
        resetDep();

        console.error(util.inspect(err));
        throw new Error('Poo ' + err);
      });
  });
});