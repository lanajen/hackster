/**
 * Converts Draftster output into Hackster's JSON model.
 */

import parseHTML from './parsers/submit';

function processCE(block, index, callback) {
  return parseHTML(block.html)
    .then(json => Promise.resolve({ type: 'CE', json }))
    .catch(err => Promise.reject(err));
}

function processCarousel(block) {
  const images = block.images
    .filter(image => image.id)
    .map(image => {
      return {
        id: image.id,
        figcaption: image.figcaption,
        uuid: image.uuid,
        name: image.name,
        url: null
      };
    });

  return { type: 'Carousel', images };
}

function processVideo(block) {
  const { id, figcaption, embed, service, type } = block.video;
  return { type: 'Video', video: [{ id, figcaption, embed, service, type }] };
}

export default function convertToJSONModel(blocks) {
  const promises = blocks.reduce((acc, block, index) => {
    switch(block.type) {
      case 'CE':
        acc.push(Promise.resolve(processCE(block)));
        break;

      case 'Carousel':
        const Carousel = processCarousel(block);
        if(Carousel.images.length) acc.push(Promise.resolve(Carousel));
        break;

      case 'Video':
        acc.push(Promise.resolve(processVideo(block)));
        break;

      default:
        acc.push(Promise.resolve(block));
        break;
    }
    return acc;
  }, []);

  return Promise.all(promises);
}