var webpack = require('webpack');

module.exports = {  
    // context: __dirname + '/assets/javascripts',
    entry: __dirname + '/assets/javascripts/follow_button/app.js',
    output: {
        path: './app/assets/javascripts/',
        filename: "bundle.js"
    },
    module: {
        loaders: [
            { test: /\.js$/, exclude: /node_modules/, loader: 'babel-loader'}
        ]
    },
    plugins: [
      new webpack.NoErrorsPlugin()
    ]
};