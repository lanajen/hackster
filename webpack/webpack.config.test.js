// E2E: Karma takes care of the entry files.  See karma.conf.js @root.
// Unit: Webpack-mocha takes care of the entry files in npm script.
var path = require('path');

module.exports = {
  devtool: 'inline-source-map',
  module: {
    loaders: [
      {
        test: /\.js?$/,
        loader: 'babel',
        exclude: /(node_modules|bower_components)/,
        query: {
          presets: ['es2015', 'react', 'stage-2'],
          plugins: ['transform-runtime', 'add-module-exports', 'rewire']
        }
      },
    //   {
    //   test: /\.js?$/,
    //   loader: 'eslint-loader',
    // },
      {
        test: /\.json$/,
        loader: "json-loader"
      }
    ]
  },
  eslint: {
    configFile: '.eslintrc',
    emitError: true
  },
  resolve: {
   root: [path.resolve(__dirname, '../app/assets/javascripts')]
 },
 extensions: ['', '.js', '.jsx']
}