import CE from '../../../../app/assets/javascripts/editor/components/ContentEditable';
import { React, TestUtils, expect, sinon, util, createShallow } from '../../helpers/phantomjs_helper.js';

describe('Content Editable Component', () => {
  const Props = {
    html: '<p>hello test!</p>',
    storeIndex: 0,
    editor: { cursorPosition: {} },
    actions: {
      getLatestHTML: sinon.spy()
    },
    hash: '1234',
    onChange: sinon.spy()
  };

  describe('when component will/did mount', () => {
    let props;

    beforeEach(() => {
      props = { ...Props };
    });

    it('should render correctly', () => {
      const { output } = createShallow(CE, props);

      expect(output.type).to.equal('div');
      expect(output.props.className).to.equal('no-outline-focus content-editable');
      expect(output.props.contentEditable).to.be.true;
    });

    it('should have a first child matching html prop', () => {
      let component = TestUtils.renderIntoDocument(<CE { ...props }/>);
      let domNode = React.findDOMNode(component);

      expect(domNode.children[0].tagName).to.equal('P');
      expect(domNode.children[0].outerHTML).to.equal(props.html);
    });
  });

  describe('when component is rerendered', () => {
    let component, domNode, props;

    beforeEach(() => {
      props = { ...Props };
      component = TestUtils.renderIntoDocument(<CE { ...props }/>);
      domNode = React.findDOMNode(component);
    });

    afterEach(() => {
      component = null;
      domNode = null;
      props.onChange.reset();
      props.actions.getLatestHTML.reset();
    });

    it('should call onChange when emitChange is fired', () => {
      expect(props.onChange).to.not.have.been.called;
      component.emitChange();
      expect(props.onChange).to.have.been.calledOnce;
    });

    it('should rerender and call componentWillRecieveProps with nextProps', () => {
      let node = document.createElement('div');
      let editable = React.render(<CE { ...props }/>, node);
      let spy = sinon.spy(editable, 'componentWillReceiveProps');
      expect(spy).to.not.have.been.called;

      let nextProps = { ...props, editor: { getLatestHTML: true } };
      React.render(<CE { ...nextProps }/>,  node);
      expect(spy).to.have.been.calledOnce;
      sinon.assert.calledWith(spy, sinon.match(nextProps));
      spy.restore();
    });

    it('should call emitChange && set action.getLatestHTML to false on rerender', () => {
      let node = document.createElement('div');
      let editable = React.render(<CE { ...props }/>, node);
      let spy = sinon.spy(editable, 'emitChange');
      expect(spy).to.not.have.been.called;

      let nextProps = { ...props, editor: { getLatestHTML: true } };
      React.render(<CE { ...nextProps }/>,  node);
      expect(spy).to.have.been.calledOnce;
      expect(props.actions.getLatestHTML).to.have.been.calledOnce;
      sinon.assert.calledWith(props.actions.getLatestHTML, sinon.match(false));
      spy.restore();
    });
  });
});

