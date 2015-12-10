import gulp from 'gulp';
import gutil from 'gulp-util';
import webpack from 'webpack';
import WebpackDevServer from 'webpack-dev-server';
import del from 'del';

let webpackConfig = {
  entry: ['babel-polyfill', __dirname + '/app/assets/javascripts/components.js'],
  watch: false,
  output: {
    path: __dirname + '/app/assets/javascripts',
    filename: 'bundle.js'
  },
  module: {
    loaders: [
      {
        include: [__dirname + '/app/assets/javascripts'],
        test: /\.js$/,
        loader: 'babel',
        exclude: /(node_modules|bower_components)/,
        query: {
          cacheDirectory: true,
          presets: ['es2015', 'react', 'stage-2'],
          plugins: ['transform-runtime', 'add-module-exports']
        }
      }
    ]
  },
  resolve: {
    extensions: ['', '.js', '.jsx', '.js.jsx']
  }
};

gulp.task('clean:js', (done) => {
  del([__dirname + '/app/assets/javascripts/bundle.js'], done());
});

gulp.task('webpack', ['clean:js'], (done) => {
  webpack(Object.create(webpackConfig), (err, stats) => {
    if(err) throw new gutil.PluginError("webpack", err);
    done();
  });
});

gulp.task('build', [ 'webpack' ], () => {
  gutil.log(gutil.colors.magenta('webpack bundle complete!'));
});

gulp.task('watch:js', () => {
  gulp.watch(__dirname + '/app/assets/javascripts/**/*.js', ['webpack']);
});

gulp.task("webpack-dev-server", function(callback) {
    // Start a webpack-dev-server
    var myConfig = Object.create(webpackConfig);
    myConfig.devtool = "eval";
    myConfig.debug = true;

    new WebpackDevServer(webpack(myConfig), {
        // server and middleware options
        publicPath: "/" + myConfig.output.publicPath,
        stats: {
          colors: true
        }
    }).listen(8080, "localhost", function(err) {
        if(err) throw new gutil.PluginError("webpack-dev-server", err);
        // Server listening
        gutil.log("[webpack-dev-server]", "http://localhost:8080/webpack-dev-server/index.html");

        // keep the server alive or continue?
        // callback();
    });
});