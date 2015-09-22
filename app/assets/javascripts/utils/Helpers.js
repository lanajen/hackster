var uuid = require('node-uuid');
module.exports = {
  // Creates URI query so that we can send Rails multiple identical keys with different values.
  toQueryString: function(obj) {
    let parts = [];
      for (let i in obj) {
        if (obj.hasOwnProperty(i)) {
          if(Array.isArray(obj[i])) {
            if(obj[i].length > 0) {
              for(let j = 0; j < obj[i].length; j++) {
                parts.push(encodeURIComponent(i) + "=" + encodeURIComponent(obj[i][j]));
              }
            } else {
              // Sends empty param to delete all from the database.
              parts.push(encodeURIComponent(i) + "=");
            }
          } else {
            parts.push(encodeURIComponent(i) + "=" + encodeURIComponent(obj[i]));
          }
        }
      }
    return parts.join("&");
  },

  isStringInBounds: function(string, min, max) {
    if(typeof string !== 'string' || string.length < min || string.length > max) {
      return false;
    } else {
      return true;
    }
  },


  isImageValid(imgFileType) {
    let isValid = false;
    let extensions = this.IMAGE_EXTENSIONS;
    for(let extension in extensions) {
      if(extensions.hasOwnProperty(extension)) {
        if(extensions[imgFileType]) {
          isValid = true;
        }
      }
    }
    return isValid;
  },

  isUrlValid: function(url, stringsToMatch) {
    let validExtensions = this.URL_EXTENSIONS;
    let key = stringsToMatch.filter(function(item) {
      return url.match(item);
    });
    // If key is empty, we have nothing to test and the url isn't valid.
    if(!key.length) { return false; }

    let regex = new RegExp(validExtensions[key[0]]);
    return url.match(regex) ? true : false;
  },

  getVideoData(url) {
    url = url.replace(/youtu\.be/, 'youtube');
    console.log('FUCK', url, url.match(/(youtube|vimeo|vine)/));
    let type = url.match(/(youtube|vimeo|vine)/);
    let service = type !== null ? type[0] : null;

    if(!service) { return null; }

    let regExps = {
      'vimeo': {
        regexp: /^.*(vimeo\.com\/)((channels\/[A-z]+\/)|(groups\/[A-z]+\/videos\/))?([0-9]+)/,
        requestLink: id => `https://vimeo.com/api/v2/video/${id}.json`,
        embed: id => `https://player.vimeo.com/video/${id}`,
        index: 5
      },
      'vine': {
        regexp: /^http(?:s?):\/\/(?:www\.)?vine\.co\/v\/([a-zA-Z0-9]{1,13})$/,
        requestLink: id => `https://vine.co/oembed.json?id=${id}`,
        embed: id => `https://vine.co/v/${id}/embed/simple\\`,
        index: 1
      },
      'youtube': {
        regexp: /^.*(youtu.be\/|v\/|e\/|u\/\w+\/|embed\/|v=)([^#\&\?]*).*/,
        requestLink: id => `https://img.youtube.com/vi/${id}/0.jpg`,
        embed: id => `https://www.youtube.com/embed/${id}`,
        index: 2
      }
    };

    let obj = regExps[service],
        match = url.match(obj.regexp);

    if(match && match.length) {
      let id = match[obj.index],
          link = obj.requestLink(id),
          embed = obj.embed(id);

      return { id: id, link: link, embed: embed, service: service };
    } else {
      // TODO: Handle Error!
      return null;
    }
  },

  getYouTubeId(url){
    let ID = '';
    url = url.replace(/(>|<)/gi,'').split(/(vi\/|v=|\/v\/|youtu\.be\/|\/embed\/)/);
    if(url[2] !== undefined) {
      ID = url[2].split(/[^0-9a-z_\-]/i);
      ID = ID[0];
    }
    else {
      ID = url;
    }
    return ID;
  },

  getVimeoId(url) {

  },

  createRandomNumber: function() {
    let random = uuid.v4();
    return random;
  },

  IMAGE_EXTENSIONS: {
    'image/png': true,
    'image/jpg': true,
    'image/jpeg': true,
    'image/gif': true,
    'image/bmp': true,
    'image/tiff': true
  },

  URL_EXTENSIONS: {
    autodesk360: /myhub\.autodesk360\.com\/([a-z0-9]+\/shares\/public\/[a-zA-Z0-9]+)/,
    bitbucket: /bitbucket\.org\/([0-9a-zA-Z_\-]+\/[0-9a-zA-Z_\-]+)/,
    circuits: /123d\.circuits\.io\/circuits\/([a-z0-9\-]+)/,
    codebender: /codebender\.cc\/sketch:([0-9]+)/,
    gist: /gist\.github\.com\/(?:[0-9a-zA-Z_\-]+\/)?([0-9a-zA-Z_\-]+)/,
    github: /github\.com\/(?:downloads\/)?([0-9a-zA-Z_\-\.]+\/[0-9a-zA-Z_\-\.]+)/,
    instagram: /instagram\.com\/p\/([a-zA-Z\-0-9]+)/,
    kickstarter: /kickstarter\.com\/projects\/([0-9a-z\-]+\/[0-9a-z\-]+)/,
    oshpark: /oshpark\.com\/shared_projects\/([a-zA-Z0-9]+)/,
    sketchfab: /sketchfab\.com\/models\/([a-z0-9]+)/,
    snip2code: /snip2code\.com\/Snippet\/([0-9]+\/[0-9a-zA-Z]+)/,
    upverter: /upverter\.com\/[^\/]+\/(?:embed\/)?(?:\#designId\=)?([a-z0-9]+)(?:\/)?(?:[^\/])*/,
    ustream: /ustream\.tv\/([a-z]+\/[0-9]+(\/[a-z]+\/[0-9]+)?)/,
    vimeo: /^.*(vimeo\.com\/)((channels\/[A-z]+\/)|(groups\/[A-z]+\/videos\/))?([0-9]+)/,
    vine: /vine\.co\/v\/([a-zA-Z0-9]+)/,
    youtube: /(?:youtube\.com|youtu\.be)\/(?:watch\?v=|v\/|embed\/)?([a-zA-Z0-9\-_]+)/,
    youmagine: /youmagine\.com\/designs\/([a-zA-Z0-9\-]+)/,
    mp4: /(.+\.(?:mp4)(?:\?.*)?)$/i
  },

  LANGUAGES: [
    {value: 'clike', label: 'C/C++ (incl. Arduino)'},
    {value: 'clojure', label: 'Clojure'},
    {value: 'cobol', label: 'Cobol'},
    {value: 'coffeescript', label: 'CoffeeScript'},
    {value: 'clike', label: 'C#'},
    {value: 'css', label: 'CSS'},
    {value: 'd', label: 'D'},
    {value: 'dart', label: 'Dart'},
    {value: 'diff', label: 'Diff'},
    {value: 'dockerfile', label: 'Dockerfile'},
    {value: 'erlang', label: 'Erlang'},
    {value: 'forth', label: 'Forth'},
    {value: 'gherkin', label: 'Gherkin'},
    {value: 'go', label: 'Go'},
    {value: 'groovy', label: 'Groovy'},
    {value: 'haml', label: 'HAML'},
    {value: 'handlebars', label: 'Handlebars'},
    {value: 'haskell', label: 'Haskell'},
    {value: 'haxe', label: 'haXe'},
    {value: 'htmlembedded', label: 'HTML'},
    {value: 'jade', label: 'Jade'},
    {value: 'clike', label: 'Java'},
    {value: 'javascript', label: 'JavaScript'},
    {value: 'julia', label: 'Julia'},
    {value: 'less', label: 'LESS'},
    {value: 'livescript', label: 'LiveScript'},
    {value: 'lua', label: 'Lua'},
    {value: 'markdown', label: 'Markdown'},
    {value: 'clike', label: 'Objective-C'},
    {value: 'pascal', label: 'Pascal'},
    {value: 'perl', label: 'Perl'},
    {value: 'php', label: 'PHP'},
    {value: 'properties', label: 'Properties'},
    {value: 'python', label: 'Python'},
    {value: 'r', label: 'R'},
    {value: 'ruby', label: 'Ruby'},
    {value: 'rust', label: 'Rust'},
    {value: 'sass', label: 'SASS'},
    {value: 'scala', label: 'Scala'},
    {value: 'smarty', label: 'Smarty'},
    {value: 'scheme', label: 'Scheme'},
    {value: 'sass', label: 'SCSS'},
    {value: 'sql', label: 'SQL'},
    {value: 'stylus', label: 'Stylus'},
    {value: 'tcl', label: 'Tcl'},
    {value: 'vbscript', label: 'VBScript'},
    {value: 'velocity', label: 'Velocity'},
    {value: 'verilog', label: 'Verilog'},
    {value: 'xml', label: 'XML'},
    {value: 'xquery', label: 'XQuery'},
    {value: 'yaml', label: 'YAML'},
  ]

};