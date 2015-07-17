import keyMirror from 'react/lib/keyMirror';

export default {

  Test: keyMirror({
    showTest: null
  }),

  Editor: keyMirror({
    isTextSelected: null,
    addMarkup: null,
    setHTML: null,
    setSelectedText: null
  }),

  ImageBucket: keyMirror({
    show: null,
    hide: null
  })

};