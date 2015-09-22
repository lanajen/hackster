import keyMirror from 'react/lib/keyMirror';

export default {

  Toolbar: keyMirror({
    showPopOver: null,
    toggleActiveButtons: null,
    setCEWidth: null
  }),

  Editor: keyMirror({
    setDOM: null,
    setInitialDOM: null,
    fetchInitialDOM: null,
    setIsFetching: null,
    setCurrentStoreIndex: null,
    setProjectData: null,
    createBlockElement: null,
    transformBlockElement: null,
    transformBlockElements: null,
    prepentCE: null,
    setFigCaptionText: null,
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
    createMediaByType: null,
    addImagesToCarousel: null,
    updateShownImage: null,
    deleteImagesFromCarousel: null,
    deleteComponent: null,
    createPlaceholderElement: null,
    resetImageUrl: null
  }),

  ImageBucket: keyMirror({
    show: null,
    hide: null
  })

};