import _ from 'lodash';

export default {

  toList(nodes) {
    let children = nodes.map(node => {
      return { ...node.json[0], tag: 'li', attribs: {} };
    });

    return {
      attribs: { hash: nodes[0].hash },
      children: children,
      content: '',
      tag: 'ul'
    };
  }
}