import async from 'async';
import request from 'superagent';
import _ from 'lodash';
import xmlParser from 'xml2js';
import Helpers from './Helpers';
import { getApiPath, getCSRFToken } from './Utils';

const ImageUtils = {

  handleImagesAsync(files, mainCallback) {
    async.map(files, function(file, callback) {
      this.handleFileReader(file, function(dataUrl, fileName, hash) {
        this.handleImageResize(dataUrl, fileName, hash, function(data) {
          return callback(null, { ...data, url: dataUrl, rawFile: file });
        });
      }.bind(this));
    }.bind(this), function(err, results) {
      if(err) console.log(err);
      mainCallback(results);
    }.bind(this));
  },

  handleFileReader(file, callback) {
    let reader = new FileReader(),
        dataUrl,
        fileName,
        hash;

    reader.onload = function(upload) {
      dataUrl = upload.target.result;
      fileName = file.name;
      hash = Helpers.createRandomNumber();

      callback(dataUrl, fileName, hash);
    }.bind(this);

    reader.readAsDataURL(file);
  },

  promisifiedFileReader(file) {
    return new Promise((resolve, reject) => {
      let reader = new FileReader();

      reader.onload = function(upload) {
        let dataUrl = upload.target.result;
        let hash = Helpers.createRandomNumber();

        resolve({ dataUrl: dataUrl, hash: hash, rawFile: file });
      };

      reader.onerror = function(err) {
        reject(err);
      };

      reader.readAsDataURL(file);
    });
  },

  promisifiedImageResize(src, dimensions) {
    return new Promise((resolve, reject) => {
      let image = new Image();
      image.onload = function(e) {
        let canvas = document.createElement('canvas'),
            width = image.width,
            height = image.height,
            dataUrl;

        canvas.width = dimensions.width;
        canvas.height = dimensions.height;
        canvas.getContext('2d').drawImage(image, 0, 0, dimensions.width, dimensions.height);
        dataUrl = canvas.toDataURL();

        resolve(dataUrl);
      };

      image.onerror = function(err) { reject(err); }
      // Fires the onload event.
      image.src = src;
    });
  },

  handleImageResize(imgSrc, fileName, hash, callback) {
    let image = new Image();
    /** Setting the crossOrigin to Anon will upset Safari CORS gods. */
    // image.crossOrigin = 'Anonymous';
    image.onload = function(e) {
      let canvas = document.createElement('canvas'),
          maxWidth = 580,
          maxHeight = 430,
          width = image.width,
          height = image.height,
          scale = Math.min((maxWidth/image.width),(maxHeight/image.height)),
          dataUrl;

      if(image.width > maxWidth || image.height > maxHeight) {
        width = (image.width * scale),
        height = (image.height * scale)
      }

      canvas.width = width;
      canvas.height = height;
      canvas.getContext('2d').drawImage(image, 0, 0, width, height);
      dataUrl = canvas.toDataURL();

      callback({ url: dataUrl, width: width, show: false, figcaption: null, name: fileName, uuid: hash });
    }.bind(this);
    // Fires the onload event.
    image.src = imgSrc;
  },

  createDataURLFromURL(src, dimensions) {
    return new Promise((resolve, reject) => {
      let image = new Image();
      image.crossOrigin = 'use credentials';
      let canvas = document.createElement("canvas"),
          canvasContext = canvas.getContext("2d"),
          width = dimensions ? dimensions.width : image.width,
          height = dimensions ? dimensions.height : image.height,
          dataURL;

      image.onload = function () {
        canvas.width = width;
        canvas.height = height;
        canvasContext.drawImage(image, 0, 0, width, height);
        dataURL = canvas.toDataURL();

        resolve(dataURL);
      };

      image.src = src;
    });
  },

  getS3AuthData(fileName) {
    fileName = fileName || 'no-name';
    return new Promise((resolve, reject) => {
      request
        .get(`${getApiPath()}/private/files/signed_url?file%5Bname%5D=${fileName}&context=no-context`)
        .withCredentials()
        .end(function(err, res) {
          err ? reject(err) : resolve(res.body);
        });
    });
  },

  postToS3(data, file, S3BucketURL, AWSAccessKeyId) {
    const form = new FormData();
    form.append('AWSAccessKeyId', AWSAccessKeyId);
    form.append('key', data.key);
    form.append('acl', 'public-read');
    form.append('policy', data.policy);
    form.append('signature', data.signature);
    form.append('success_action_status', '201');
    form.append('file', file.rawFile);

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

  postURLToServer(url, projectID, modelType, csrfToken, fileType) {
    let params = {
      'file_url': url,
      'file_type': fileType || 'image',
      'attachable_id': projectID,
      'attachable_type': modelType
    };

    return new Promise((resolve, reject) => {
      request
        .post(`${getApiPath()}/private/files`)
        .set('X-CSRF-Token', csrfToken)
        .send(params)
        .withCredentials()
        .end(function(err, res) {
          err ? reject(err) : resolve(res);
        });
    });
  },

  deleteImageFromServer(id) {
    return new Promise((resolve, reject) => {
      request
        .del(`${getApiPath()}/private/files`)
        .set('X-CSRF-Token', getCSRFToken())
        .send({ id })
        .end((err, res) => {
          err ? reject(err) : resolve(res.body);
        });
    });
  },

  postRemoteURL(url, fileType) {
    const form = new FormData();
    form.append('file_type', fileType);
    form.append('file_url', url);

    return new Promise((resolve, reject) => {
      request
        .post(`${getApiPath()}/private/files/remote_upload`)
        .set('X-CSRF-Token', getCSRFToken())
        .send(form)
        .withCredentials()
        .end((err, res) => {
          err ? reject(err) : resolve(res.body);
        });
    });
  },

  pollJob(jobId) {
    return new Promise((resolve, reject) => {
      let poll = setInterval(() => {
        request
          .get(`${getApiPath()}/private/files/remote_upload?job_id=${jobId}`)
          .withCredentials()
          .end((err, res) => {
            if (err || res.body.status === 'failed') {
              clearInterval(poll);
              reject(err);
            } else if (res.body.status === 'complete') {
              clearInterval(poll);
              resolve(res.body);
            }
          });
      }, 500);
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