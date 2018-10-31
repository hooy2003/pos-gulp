gulp         = require('gulp')
del          = require('del')
cache        = require('gulp-cache')
uglify       = require('gulp-uglify')
concat       = require('gulp-concat')
jshint       = require('gulp-jshint')
broeserSync  = require('browser-sync')
sitemap      = require('gulp-sitemap')
imagemin     = require('gulp-imagemin')
sass         = require('gulp-ruby-sass')
minifycss    = require('gulp-minify-css')
extender     = require('gulp-html-extend')
minifyHTML   = require('gulp-minify-html')
autoprefixer = require('gulp-autoprefixer')

gulp.task 'browser-sync', ['rebuild'], ->
  broeserSync({
    server: {
      baseDir: './dist/'
    },
    port: 8080,
    host: '0.0.0.0',
    ui: {
      port: 8081
    }
  })

gulp.task 'rebuild', ->
  broeserSync.reload()

gulp.task 'watch', ->
  gulp.watch(['./dist/**/*.*'], ['rebuild'])
  gulp.watch(['./src/**/*.html'], ['extend'])
  gulp.watch(['./src/**/*.scss'], ['styles'])
  gulp.watch(['./src/**/*.js'], ['js'])
  gulp.watch(['./src/**/*.jpg','./src/**/*.png'], ['image'])

gulp.task 'styles', -> 
  return sass('./src/scss/app.scss', { style: 'compressed' })
  .pipe autoprefixer('last 2 version', 'safari 5', 'ie 8', 'ie 9', 'opera 12.1', 'ios 6', 'android 4')
  .pipe concat('app.css')
  # .pipe minifycss()
  .pipe gulp.dest('./dist/css/')

gulp.task 'module-js', -> 
  gulp.src('./node_modules/jquery/dist/jquery.min.js')
  .pipe concat('jquery.min.js')
  .pipe gulp.dest('./dist/js/')
  gulp.src('./semantic/dist/semantic.min.js')
  .pipe concat('semantic.min.js')
  .pipe gulp.dest('./dist/js/')

gulp.task 'module-css', -> 
  gulp.src('./semantic/dist/semantic.min.css')
  .pipe concat('semantic.min.css')
  .pipe gulp.dest('./dist/css/')

gulp.task 'extend', -> 
  gulp.src('./src/html/*.html') 
  .pipe extender({annotations:false,verbose:false})
  # .pipe minifyHTML()
  .pipe gulp.dest('./dist/')

gulp.task 'js', -> 
  gulp.src('./src/**/*.js') 
  .pipe uglify()
  .pipe gulp.dest('./dist/')

gulp.task 'image', -> 
  gulp.src(['./src/**/*.jpg','./src/**/*.png','./src/**/*.svg']) 
  .pipe cache(imagemin({optimizationLevel: 3, progressive: true, interlaced: true}))
  .pipe gulp.dest('./dist/')

gulp.task 'clean', -> 
  del ['./dist/css','./dist/js','./dist/gallery', './dist/img', './dist/**/*.html']

gulp.task 'sitemap', ->
    gulp.src('dist/**/*.html', { read: false })
        .pipe sitemap({ siteUrl: 'http://yulive.cn' })
        .pipe gulp.dest('./dist/')

gulp.task 'build', ['styles', 'js', 'image', 'extend', 'module-js', 'module-css']

gulp.task 'default', ['browser-sync', 'watch']