'use strict';

module.exports = {
  entry: {
    bundle: ['babel-polyfill', __dirname + '/../app/assets/javascripts/components.js'],
    mouser_bundle: ['babel-polyfill', __dirname + '/../app/assets/javascripts/mouser_contest/bundleEntry.js']
  },
  output: {
    path: __dirname + '/../app/assets/javascripts',
    filename: '[name].js'
  },
  module: {
    preLoaders: [
      {
        test: /\.jsx?$/,
        loader: 'eslint-loader',
        exclude: /(node_modules|bower_components)/
      }
    ],
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
    extensions: ['', '.js', '.jsx', 'json']
  },
  eslint: {
    configFile: '.eslintrc',
    emitError: true
  }
};