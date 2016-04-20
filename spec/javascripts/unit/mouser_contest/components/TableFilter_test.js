import React from 'react';
import ReactDOM from 'react-dom';
import expect from 'expect';
import { inspect } from 'util';
import { Simulate, createRenderer, renderIntoDocument, findRenderedDOMComponentWithTag } from 'react-addons-test-utils';

import TableFilter from 'mouser_contest/components/TableFilter';

function setupProps(props) {
  props = props || {};
  return {
    label: 'Vendor',
    options: [ 'Coors', 'Miller', 'PBR' ],
    value: 'default',
    onChange: () => {},
    ...props
  };
}

function setupShallow(props) {
  const { label, options, value, onChange } = props;
  let renderer = createRenderer();
  renderer.render(<TableFilter label={label} options={options} value={value} onChange={onChange} />);
  const output = renderer.getRenderOutput();

  return { renderer, output, props };
}

function setupDOM(props) {
  const { label, options, value, onChange } = props;

  let div = document.createElement('div');
  let body = document.getElementsByTagName('body')[0];
  body.appendChild(div);
  let component = ReactDOM.render(<TableFilter label={label} options={options} value={value} onChange={onChange} />, div);

  return {
    props,
    component,
    div,
    body
  }
}

describe('TableFilter', () => {
  it('should render a span', () => {
    const { output } = setupShallow(setupProps());

    expect(output.type).toEqual('span');
  });

  it('should render a label as a first child', () => {
    const label = 'Beers!';
    const { output } = setupShallow(setupProps({ label }));

    expect(output.props.children[0].type).toEqual('label');
    expect(output.props.children[0].props.children).toEqual(label);
  });

  it('should render a select as a second child', () =>  {
    const value = 'PBR';
    const { output } = setupShallow(setupProps({ value }));

    expect(output.props.children[1].type).toEqual('select');
    expect(output.props.children[1].props.value).toEqual(value);
  });

  it('should render props.options and prepend a default option', () => {
    const options = [ 'Sierra', 'Ballast', 'Deschutes' ];
    const { output } = setupShallow(setupProps({ options }));

    const select = output.props.children[1];
    const renderedOptionsValues = React.Children.map(select.props.children, option => option.props.value);

    expect(options).toNotEqual(renderedOptionsValues);
    expect(['default'].concat(options)).toEqual(renderedOptionsValues);
  });

  it('should trigger an onChange callback when the select value has changed', () => {
    const props = setupProps({ onChange: expect.createSpy() });
    const { label, options, value, onChange } = props;

    class Wrapper extends React.Component {
      constructor() {
        super();
      }

      render() {
        return (
          <TableFilter label={label} options={options} value={value} onChange={onChange} />
        );
      }
    }

    const component = renderIntoDocument(<Wrapper />);
    const select = findRenderedDOMComponentWithTag(component, 'select');

    expect(onChange).toNotHaveBeenCalled();

    Simulate.change(select, { target: { value: 'Value Changed!' }});
    expect(onChange).toHaveBeenCalledWith(label.toLowerCase(), 'Value Changed!');

    onChange.reset();
  });

});