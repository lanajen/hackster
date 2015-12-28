'use strict';

module.exports = {
  entry: ['babel-polyfill', __dirname + '../../app/assets/javascripts/components.js'],
  output: {
    path: __dirname + '../../app/assets/javascripts',
    filename: 'bundle.js'
  },
  module: {
    loaders: [
      {
        test: /\.jsx?$/,
        loader: 'babel',
        exclude: /(node_modules|bower_components)/,
        query: {
          cacheDirectory: true,
          presets: ['es2015', 'react', 'stage-2'],
          plugins: ['transform-runtime', 'add-module-exports']
        }
      },
      {
        test: /\.json$/,
        loader: "json-loader"
      }
    ]
  },
  resolve: {
    extensions: ['', '.js', '.jsx', '.js.jsx', 'json']
  }
};