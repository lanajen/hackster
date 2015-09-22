import async from 'async';
import request from 'superagent';
import _ from 'lodash';
import xmlParser from 'xml2js';

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
      callback({ url: dataUrl, width: width, show: false, figcaption: null });
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

  getS3AuthData(fileName) {
    return new Promise((resolve, reject) => {
      request
        .get('/files/signed_url?file%5Bname%5D='+ fileName +'&context=no-context')
        .end(function(err, res) {
          err ? reject(err) : resolve(res.body);
        });
    });
  },

  postToS3(data, file, S3BucketURL, AWSAccessKeyId) {
    const blob = dataURIToBlob(file.url);
    const form = new FormData();
    form.append('AWSAccessKeyId', AWSAccessKeyId);
    form.append('key', data.key);
    form.append('acl', 'public-read');
    form.append('policy', data.policy);
    form.append('signature', data.signature);
    form.append('success_action_status', '201');
    form.append('file', blob);

    return new Promise((resolve, reject) => {
      request
        .post(S3BucketURL)
        .accept('application/xml')
        .send(form)
        .end(function(err, S3Response) {
          if(err) reject(err);
          xmlParser.parseString(S3Response.text, function(err, parsedXML) {
            // This is our S3 URL for the image.  
            err ? reject(err) : resolve(parsedXML.PostResponse.Location[0]);
          });
        });
    });
  },

  postURLToServer(url, projectID, csrfToken, fileType, context, additionalParams) {
    let params = {
        'file_url': url,
        'file_type': fileType,
        'context': context
      };

      if(additionalParams !== undefined && additionalParams instanceof Object) {
        params = _.extend({}, params, additionalParams);
      }

      return new Promise((resolve, reject) => {
        request
          .post('/files')
          .set('X-CSRF-Token', csrfToken)
          .send(params)
          .end(function(err, res) {
            err ? reject(err) : resolve(res);
          });
      });
  },

  dataURIToBlob(dataURI) {
    let byteString, 
        mimestring,
        content = [];

    if(dataURI.split(',')[0].indexOf('base64') !== -1 ) {
        byteString = atob(dataURI.split(',')[1]);
    } else {
        byteString = decodeURI(dataURI.split(',')[1]);
    }

    mimestring = dataURI.split(',')[0].split(':')[1].split(';')[0];

    for (let i = 0; i < byteString.length; i++) {
        content[i] = byteString.charCodeAt(i);
    }

    return new Blob([new Uint8Array(content)], {type: mimestring});
  }

};

export default ImageUtils;