import async from 'async';
import request from 'superagent';

const ImageUtils = {

  handleImagesAsync(files, mainCallback) {
    async.map(files, function(file, callback) {
      this.handleFileReader(file, function(dataUrl) {
        this.handleImageResize(dataUrl, function(url, width) {
          callback(null, url, width);
        });
      }.bind(this));
    }.bind(this), function(err, results) {
      if(err) console.log(err);

      mainCallback(results);
    }.bind(this));
  },

  handleFileReader(file, callback) {
    let reader = new FileReader(),
        dataUrl;

    reader.onload = function(upload) {
      dataUrl = upload.target.result;
      callback(dataUrl);
    }.bind(this);

    reader.readAsDataURL(file);
  },

  handleImageResize(imgSrc, callback) {
    let image = new Image();
    image.crossOrigin = 'Anonymous';
    image.onload = function(e) {
      // Resize the image.
      let canvas = document.createElement('canvas'),
          maxSize = 750,
          isImageOverSize = false,
          width = image.width,
          height = image.height,
          dataUrl;

      if (width > height) {
          if (width > maxSize) {
              isImageOverSize = true;
              height *= maxSize / width;
              width = maxSize;
          }
      } else {
          if (height > 514) {
              isImageOverSize = true;
              width *= 514 / height;
              height = 514;
          }
      }

      if(isImageOverSize) {
        canvas.width = width;
        canvas.height = height;
        canvas.getContext('2d').drawImage(image, 0, 0, width, height);
        dataUrl = canvas.toDataURL('image/jpeg');
      } else {
        canvas.width = width;
        canvas.height = height;
        canvas.getContext('2d').drawImage(image, 0, 0, width, height);
        dataUrl = canvas.toDataURL('image/jpeg');
      }

      callback({url: dataUrl, width: width});
    }.bind(this);
    // Fires the onload event.
    image.src = imgSrc;
  },

  createDataURLFromURL(src) {
    return new Promise((resolve, reject) => {
      let image = new Image();
      image.crossOrigin = 'use credentials';
      let canvas = document.createElement("canvas"),
          canvasContext = canvas.getContext("2d"),
          dataURL;

      image.onload = function () {
        canvas.width = image.width;
        canvas.height = image.height;
        canvasContext.drawImage(image, 0, 0, image.width, image.height);
        dataURL = canvas.toDataURL();

        resolve(dataURL);
      };

      image.src = src;
    });
  },

  fetchImageAndTransform(videoData, projectId, csrfToken) {
    return new Promise((resolve, reject) => {
      request
        .post(`/api/v1/projects/${projectId}/video_data`)
        .set('X-CSRF-Token', csrfToken)
        .send({ videoData: videoData })
        .end((err, res) => {
          if(err) reject(err);
          let image = res.body.poster;

          if(image === null) {
            // TODO: Handle err;
            reject('Error');
          }

          this.handleImageResize(image, function(imageData) {
            resolve(Object.assign({}, imageData, videoData)); 
          });

        });
    });
  }

};

export default ImageUtils;