import keyMirror from 'keymirror';

export default {

  Toolbar: keyMirror({
    showPopOver: null,
    toggleActiveButtons: null,
    setCEWidth: null
  }),

  Editor: keyMirror({
    setDOM: null,
    hasUnsavedChanges: null,
    setInitialDOM: null,
    fetchInitialDOM: null,
    setIsFetching: null,
    setCurrentStoreIndex: null,
    setProjectData: null,
    createBlockElement: null,
    createBlockElementWithChildren: null,
    transformBlockElement: null,
    transformBlockElements: null,
    prependCE: null,
    insertCE: null,
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
    resetImageUrl: null,
    removeImageFromList: null,
    isDataLoading: null,
    splitBlockElement: null,
    toggleErrorMessenger: null,
    handlePastedHTML: null,
    toggleIE: null
  }),

  ImageBucket: keyMirror({
    show: null,
    hide: null
  })

};