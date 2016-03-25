// Karma takes care of the entry files.  See karma.conf.js @root.

module.exports = {
  devtool: 'inline-source-map',
  module: {
    loaders: [
      {
        test: /\.js$/,
        loader: 'babel?plugins=rewire',
        exclude: /node_modules/
      },
      {
        test: /\.js?$/,
        loader: 'babel',
        exclude: /(node_modules|bower_components)/,
        query: {
          presets: ['es2015', 'react', 'stage-2'],
          plugins: ['transform-runtime', 'add-module-exports']
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
  }
}