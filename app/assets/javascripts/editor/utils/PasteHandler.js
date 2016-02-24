import Utils from './DOMUtils';
import Parser from './Parser';
import { domWalk } from './Traversal';

export default {

  handleText(e, selectionData) {
    let { pastedText, dataType } = this.getTextFromClipboard(e);

    if(pastedText.length < 1) { return null; }

    if(dataType === 'text') {
      pastedText = Parser.stringifyLineBreaksToParagraphs(pastedText, parentNode.nodeName);
    }

    if(pastedText.match(/(<table)/g)) {
      let liveNode = Parser.toLiveHtml(pastedText, { body: true });
      let newNode = this.handleTables(liveNode);
      pastedText = newNode.innerHTML;
    }
  },

  getTextFromClipboard(e) {
    let pastedText, dataType;
    if(window && window.clipboardData && window.clipboardData.getData) {
      /** IE */
      pastedText = window.clipboardData.getData('Text');
      dataType = 'html';
    } else if(e.clipboardData && e.clipboardData.getData) {
      let clipboardDataTypes = [].slice.apply(e.clipboardData.types);
      if(clipboardDataTypes.indexOf('text/html') === 1) {
        pastedText = e.clipboardData.getData('text/html');
        dataType = 'html';
      } else {
        pastedText = e.clipboardData.getData('text/plain');
        dataType = 'text';
      }
    }
    return { pastedText, dataType };
  },

  handleTables(liveNode) {
    let table;
    domWalk(liveNode, (child, root, depth) => {
      if(child.nodeName === 'TABLE') {
        table = child;
      } else if(child.nodeName === 'TR' && child.textContent.length) {
        let p = document.createElement('p');
        p.textContent = child.textContent;
        liveNode.appendChild(p);
      }
      return child;
    });
    liveNode.contains(table) ? liveNode.removeChild(table) : true;
    return liveNode;
  }
}