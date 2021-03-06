var webpackConfig = require('./webpack/webpack.config.test');

module.exports = function (config) {
  config.set({
    singleRun: true,
    frameworks: [ 'mocha' ],
    colors: true,
    files: [
      './node_modules/babel-polyfill/dist/polyfill.min.js',
      './spec/javascripts/unit/**/*_test.js'
      // './spec/javascripts/unit/mouser_contest/components/TableFilter_test.js'
    ],
    preprocessors: {
      './spec/javascripts/unit/**/*_test.js': ['webpack']
      // './spec/javascripts/unit/**/*_test.js': ['webpack', 'sourcemap']
    },
    // logLevel: 'LOG_INFO',
    reporters: [ 'mocha' ],
    mochaReporter: {
      showDiff: true
    },
    webpack: webpackConfig,
    webpackMiddleware: {
      noInfo: true
    }
  });
}