import keyMirror from 'react/lib/keyMirror';

export default {

  Toolbar: keyMirror({
    showPopOver: null,
    toggleActiveButtons: null,
    setCEWidth: null
  }),

  Editor: keyMirror({
    setDOM: null,
    fetchInitialDOM: null,
    createBlockElement: null,
    createBlockElementWithChildren: null,
    transformBlockElement: null,
    transformBlockElements: null,
    cleanElement: null,
    removeBlockElements: null,
    handleUnorderedList: null,
    wrapOrUnwrapBlockElement: null,
    removeListItemFromList: null,
    transformListItemsToBlockElements: null,
    isEditable: null,
    getLatestHTML: null,
    forceUpdate: null,
    setCursorPosition: null,
    setCursorToNextLine: null,
    isHovered: null,
    toggleImageToolbar: null,
    updateImageToolbarData: null,
    createCarousel: null,
    addImagesToCarousel: null,
    deleteImagesFromCarousel: null,
    handleVideo: null,
    createPlaceholderElement: null
  }),

  ImageBucket: keyMirror({
    show: null,
    hide: null
  })

};