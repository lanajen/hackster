import React from 'react/addons';
import ReactDOM from 'react-dom';
import { Simulate, renderIntoDocument, findRenderedDOMComponentWithClass, findRenderedComponentWithType } from 'react-addons-test-utils';
import expect from 'expect';
import util from 'util';
import ListsDropdown from 'lists_dropdown/app';

describe('list dropdown', () => {

  it('should open dropdown', () => {
    const component = renderIntoDocument(<ListsDropdown/>);
    const openDropdown = findRenderedDOMComponentWithClass(component, 'toggle-lists-btn');

    expect(component.state.isDropdownOpen).toBe(false);
    Simulate.click(openDropdown);
    expect(component.state.isDropdownOpen).toBe(true);

  });

  it('should close when the page is clicked', () => {
    const component = renderIntoDocument(<ListsDropdown/>);
    const openDropdown = findRenderedDOMComponentWithClass(component, 'toggle-lists-btn');

    expect(component.state.isDropdownOpen).toBe(false);
    Simulate.click(openDropdown);
    expect(component.state.isDropdownOpen).toBe(true);
    document.body.click();
    expect(component.state.isDropdownOpen).toBe(false);
  });

});