var gulp = require('gulp');
var browserify = require('browserify');
var babelify = require('babelify');
var mochaPhantomJS = require('gulp-mocha-phantomjs');
var source = require('vinyl-source-stream');
var glob = require('glob');
var del = require('del');

gulp.task('clean-test-bundle', function() {
  del([ './spec/javascripts/bundle.js' ]);
});

gulp.task('browserify-test', function() {
  var files = glob.sync('./spec/javascripts/**/*_test.js');
  return browserify({ entries: files })
    .transform(babelify.configure({
      plugins: [ require('babel-plugin-rewire') ]
    }))
    .bundle()
    .pipe(source('bundle.js'))
    .pipe(gulp.dest('./spec/javascripts/'));
});

gulp.task('test', ['clean-test-bundle', 'browserify-test'], function() {
  return gulp
    .src('./spec/javascripts/runner.html')
    .pipe(mochaPhantomJS({ reporter: 'spec' }));
});