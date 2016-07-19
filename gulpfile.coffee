gulp = require 'gulp'
gutil = require 'gulp-util'
bower = require 'bower'
concat = require 'gulp-concat'
sass = require 'gulp-sass'
pug = require 'gulp-pug'
coffee = require 'gulp-coffee'
watch = require 'gulp-watch'
minifyCss = require 'gulp-minify-css'
rename = require 'gulp-rename'
notify = require 'gulp-notify'
changed = require 'gulp-changed'
sh = require 'shelljs'
browserSync = require 'browser-sync'
reload = browserSync.reload
htmlreplace = require 'gulp-html-replace'
file = require 'file'
_ = require('lodash')


###
# sass_compile?
# sass_compile = sass({pretty: true})?
# on 'end'?
###

paths =
  sass: [ './scss/**/*.sass' ]
  pug: [ './pug/**/*.pug' ]
  coffee: [ './coffee/**/*.coffee' ]
  css: [ './www/css/custom/**/*.css' ]
  js: [ './www/js/**/*.js', './www/lib/vendor/**/*.js']

gulp.task 'default', [ 'watch' ]

gulp.task 'init', ->
  sh.exec 'gulp sass'
  sh.exec 'gulp pug'
  sh.exec 'gulp coffee'

gulp.task 'sass', ->
  #sass_compile = sass({pretty: true})
  #sass_compile.on 'error', (e) ->
  #  gutil.log e
  #  sass_compile.end()

  gulp.src(paths.sass)
    .pipe(changed './www/csss/')
    #.pipe(sass_compile)
    .pipe(sass({outputStyle: 'expanded'}).on('error', sass.logError))
    .pipe(gulp.dest('./www/css/'))
    .on 'end', ->
  return

gulp.task 'pug',  ->
  #pug_compile = pug({pretty: true})
  #pug_compile.on 'error', (e)->
  #  gutil.log e
  #  pug_compile.end()

  gulp.src(paths.pug)
    .pipe(changed('./www/templates', {extension: '.html'}))
    .pipe pug({pretty: true}).on 'error',(e) ->
      gutil.log e
    #.pipe(pug_compile)
    #.pipe notify "pug compile run"
    .pipe(gulp.dest('./www/templates/'))
    #.pipe(notify
    #  #onLast: true,
    #  message: 'pug compile run'
    #)
    .on('end', ->)


gulp.task 'coffee', ->
  gulp.src('./coffee/*.coffee')
    #.pipe notify "coffee compile run"
    .pipe(coffee(bare: true)
    .on('error', gutil.log))
    .pipe gulp.dest('./www/js/')
  return

gulp.task 'watch', ->
  gulp.watch paths.sass, [ 'sass' ]
  gulp.watch paths.pug, [ 'pug' ]
  gulp.watch paths.coffee, [ 'coffee' ]
  watch (paths.js.concat paths.css), {events: ['add', 'unlink']}, ->
    gulp.start 'replace-index-assets'
  #sh.exec 'ionic serve'
  return

get_assets_from = (dir, file_type)->
  fullname_files = []
  # a incursive loop function
  file.walkSync dir, (dirPath, dirs, files)->
    matched_files = _.filter(files, (file)-> _.endsWith(file, ".#{file_type}"))
    fullname_files = _.concat(fullname_files, _.map(matched_files, (file)->
      dirPath + '/' + file))
  fullname_files
  

gulp.task 'replace-index-assets', ->
  process.chdir('www')
  vendor_css_files = get_assets_from('css/vendor', 'css')
  all_css_files = _.concat(vendor_css_files, (get_assets_from('css/custom', 'css')))
  vendor_js_files = get_assets_from('lib/vendor', 'js')
  all_js_files = _.concat(vendor_js_files, (get_assets_from('js', 'js')))
    
  gulp.src('index.html')
    .pipe(htmlreplace {
      'css': all_css_files
      'js': all_js_files
    }, {
      keepBlockTags: true
    })
    .pipe gulp.dest './'
  process.chdir('..')

  

