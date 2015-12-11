import { Toolbar } from '../constants/ActionTypes';

export function showPopOver(bool, props) {
  return {
    type: Toolbar.showPopOver,
    bool: bool,
    props: props
  };
}

export function toggleActiveButtons(list) {
  return {
    type: Toolbar.toggleActiveButtons,
    list: list
  };
}

export function setCEWidth(width) {
  return {
    type: Toolbar.setCEWidth,
    width: width
  };
}