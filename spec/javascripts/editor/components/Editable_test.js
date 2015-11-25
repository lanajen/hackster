import Editable from '../../../../app/assets/javascripts/editor/components/Editable';
import DOMUtils from '../../../../app/assets/javascripts/editor/utils/DOMUtils';
import { React, TestUtils, expect, sinon, util, createShallow } from '../../helpers/phantomjs_helper.js';

function createExpectedDOM(window) {
  let panel = document.createElement('div');
  let form = document.createElement('form');
  panel.setAttribute('id', 'story');
  form.classList.add('simple_form');

  window.document.body.appendChild(panel);
  panel.appendChild(form);

  window.pe = {
    serializeForm: sinon.spy()
  };
}

function resetSpiesFromActions(props) {
  Object.keys(props.actions).forEach(key => {
    if(props.actions[key].isSinonProxy) {
      props.actions[key].reset();
    }
  });
}

describe('Editable Component', () => {
  /** Sets up the DOM with needed elements for componentWillMount & componentDidMount. */
  createExpectedDOM(window);

  const Props = {
    actions: {
      setProjectData: sinon.spy(),
      setIsFetching: sinon.spy(),
      fetchInitialDOM: sinon.spy(),
      setCEWidth: sinon.spy()
    },
    editor: {
      dom: [],
      cursorPosition: {
        rootHash: '1234',
        node: React.createElement('p', { 'data-hash': '4321' })
      }
    },
    toolbar: {
      CEWidth: null
    },
    S3BucketURL: 'S3',
    AWSAccessKeyId: 'AWS'
  };
  let locationStub;

  beforeEach(() => {
    locationStub = sinon.stub(DOMUtils, 'getWindowLocationHref', () => {
      return 'http://www.test.com/1234';
    });
  });

  afterEach(() => {
    locationStub.restore();
  });

  /**
   * Component Will Mount && Did Mount
   */
  describe('when component will/did mount', () => {
    let component, props;

    beforeEach(() => {
      props = { ...Props };
      component = TestUtils.renderIntoDocument(<Editable { ...props }/>);
    });

    afterEach(() => {
      resetSpiesFromActions(props);
    });

    it('should render correctly', () => {
      let { output } = createShallow(Editable, props);
      expect(output.type).to.equal('div');
      expect(output.props.className).to.equal('box');
    });

    it('should call actions.setProjectData with projectId, csrfToken, S3BucketURL & AWSAccessKeyId', () => {
      expect(props.actions.setProjectData).to.have.been.called;
      expect(props.actions.setProjectData.args[0]).to.eql([ '1234', 'token', 'S3', 'AWS' ]);
    });

    it('should call setIsFetching && fetchInitialDOM when editor.dom.length is 0', () => {
      expect(props.editor.dom.length).to.equal(0);
      expect(props.actions.setIsFetching).to.have.been.called;
      expect(props.actions.fetchInitialDOM).to.have.been.called;
    });

    it('should not call setIsFetching && fetchInitialDOM if editor.dom has a length', () => {
      props = { ...props, editor: { dom: [{}, {}, {}] }};
      resetSpiesFromActions(props);
      TestUtils.renderIntoDocument(<Editable { ...props }/>);

      expect(props.editor.dom.length).to.equal(3);
      expect(props.actions.setIsFetching).to.not.have.been.called;
      expect(props.actions.fetchInitialDOM).to.not.have.been.called;
    });

    it('should create an input with an id of story_json', (done) => {
      setTimeout(() => {
        let input = document.getElementById('story_json');
        expect(input.nodeName).to.equal('INPUT');
        expect(input.getAttribute('id')).to.equal('story_json');
        done();
      }, 500);
    });

    it('should call window.pe.serializeForm', () => {
      expect(window).to.have.property('pe');
      expect(window.pe.serializeForm).to.have.been.called;
    });

    it('should call actions.setCEWidth', () => {
      expect(props.actions.setCEWidth).to.have.been.called;
    });
  });
});