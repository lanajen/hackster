import { Editor } from '../constants/ActionTypes';

export function setHTML(html) {
  return {
    type: Editor.setHTML,
    html: html
  };
}

export function setSelectedText(data) {
  return {
    type: Editor.setSelectedText,
    data: data
  };
}

export function isTextSelected(bool) {
  return {
    type: Editor.isTextSelected,
    bool: bool
  };
}

export function addMarkup(tag) {
  return {
    type: Editor.addMarkup,
    tag: tag
  };
}