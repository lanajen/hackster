/**
 * Converts Draftster output into Hackster's JSON model.
 */

import parseHTML from './parsers/submit';

function processCE(block, index, callback) {
  return parseHTML(block.html)
    .then(json => {
      return callback({ type: 'CE', json }, index);
    })
    .catch(err => console.error(err));
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
  const json =  blocks.reduce((acc, block, index) => {
    switch(block.type) {
      case 'CE':
        processCE(block, index, (updatedBlock, i) => {
          if(updatedBlock.json.length) acc.splice(i, 0, updatedBlock);
        });
        break;

      case 'Carousel':
        const Carousel = processCarousel(block);
        if(Carousel.images.length) acc.push(Carousel);
        break;

      case 'Video':
        acc.push(processVideo(block));
        break;

      default:
        acc.push(block);
        break;
    }

    return acc;
  }, []);

  return Promise.resolve(json);
}