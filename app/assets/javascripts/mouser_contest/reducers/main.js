import store from '../store.js'


const initialState = {
  Playlist: null,
  nowPlayingDescription: {
    name: null,
    aliases: null,
    profile: null,
    groups: null,
    urls: null,
    images: null
  },
  nowPlayingURL: null,
  backupDescription: null
}


const MainReducer = (state = initialState, action) => {

  switch(action.type) {
    case 'testing':
      console.log('just testing');

    default:
      return state;
  }
}



export default MainReducer