'use strict';

var webpack = require('webpack');
var baseConfig = require('./webpack.config.base');

var config = Object.create(baseConfig);
config.plugins = [
  function(){
    this.plugin('done', function(stats) {
      if(stats.compilation.errors && stats.compilation.errors.length && process.argv.indexOf('--watch') === -1) {
        process.on('beforeExit', function() {
          process.exit(1);
        });
      }
    });
  },
  new webpack.optimize.OccurenceOrderPlugin(),
  new webpack.DefinePlugin({
    'process.env.NODE_ENV': JSON.stringify('production')
  }),
  new webpack.optimize.UglifyJsPlugin({
    compressor: {
      screw_ie8: true,
      warnings: false
    }
  })
];

module.exports = config;