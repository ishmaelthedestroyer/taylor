module.exports = (grunt) ->
  # config
  fileConfig =
    dir:
      tmp: 'tmp/'
      dist: 'dist/'

    dist:
      client: 'dist/js/taylor.js'
      css: 'dist/css/taylor.css'

    files:
      mock: [
        'mockup/*'
        'mockup/**/*'
      ]
      meta: [
        'Procfile'
        'TODO.md'
        'bower.json'
        'package.json'
        '.bowerrc'
        '.gitignore'
        '.nodemonignore'
        '.jshintrc'
      ]
      server: [
        '*.*'
        'lib/*.*',
        'app/bin/*.*'
        'app/models/*.*'
        'app/controllers/*.*'
        'config/**/*.*'
      ]
      client: [
        'js/taylor.*'
      ]
      html: [
      ]
      css: [
        'css/taylor.css'
      ]
      favicon: [
        'favicon.ico'
      ]
      img: [
        'img/**'
      ]
      vendor:
        'vendor/**'
      all: []
      clientTmp: []

  for file in fileConfig.files.client
    fileConfig.files.clientTmp.push 'tmp/'+file

  fileConfig.files.all.push file for file in fileConfig.files.server
  fileConfig.files.all.push file for file in fileConfig.files.client
  fileConfig.files.all.push file for file in fileConfig.files.html
  fileConfig.files.all.push file for file in fileConfig.files.css

  # load tasks
  require('load-grunt-tasks')(grunt)

  # task config
  taskConfig =
    # `package.json` file read to access meta data
    pkg: grunt.file.readJSON 'package.json'

    # banner placed at top of compiled source files
    meta:
      '/** \n' +
      ' * <%= pkg.name %> - v<%= pkg.version %> - ' +
      '<%= grunt.template.today("yyyy-mm-dd") %>\n' +
      ' * <%= pkg.homepage %> \n' +
      ' * \n' +
      ' * Copyright (c) <%= grunt.template.today("yyyy") %> ' +
      '<%= pkg.author %>\n' +
      ' * Licensed <%= pkg.licenses.type %> <<%= pkg.licenses.url %>>\n' +
      ' * */\n'

    concurrent:
      dev:
        options:
          logConcurrentOutput: true
        tasks: [
          'watch'
          'nodemon:dev'
        ]

    nodemon:
      dev:
        options:
          file: '<%= dir.dist %>app.js'

    # watch files for changes
    watch:
      server:
        files: [
          '<%= files.server %>'
        ]
        tasks: [
          'build:server'
        ]
      client:
        files: [
          '<%= files.client %>'
        ]
        tasks: [
          'build:client'
        ]
      css:
        tasks: [
          'build:css'
        ]
        files: [
          '<%= files.css %>'
        ]
      assets:
        tasks: [
          'build:assets'
        ]
        files: [
          '<%= files.img %>'
          '<%= files.favicon %>'
          '<%= files.vendor %>'
        ]

    # creates changelog on a new version
    changelog:
      options:
        dest: 'CHANGELOG.md'
        template: 'changelog.tpl'

    # increments version number, etc
    bump:
      options:
        files: [
          'package.json'
          'bower.json'
        ]
        commit: true
        commitMessage: 'chore(release): v%VERSION%'
        commitFiles: [
          'package.json'
          'bower.json'
        ]
        createTag: false
        tagName: 'v%VERSION%'
        tagMessage: 'Version %VERSION%'
        push: false
        pushTo: 'origin'

    # directories to clean when `grunt clean` is executed
    clean:
      tmp: [
        '<%= dir.tmp %>'
      ]
      dist: [
        '<%= dir.dist %>'
      ]
      server:
        expand: true
        cwd: '<%= dir.dist %>'
        src: [
          '<%= files.meta %>'
          '<%= files.server %>'
        ]
        filter: (filename) ->
          split = filename.split '.'
          ext = split[split.length - 1]
          return ext is 'js'
      client:
        expand: true
        cwd: '<%= dir.dist %>'
        src: [
          '<%= dist.client %>'
        ]
        filter: (filename) ->
          split = filename.split '.'
          ext = split[split.length - 1]
          return ext is 'js'
      html:
        expand: true
        cwd: '<%= dir.dist %>'
        src: [
          '<%= files.html %>'
        ]
        filter: (filename) ->
          split = filename.split '.'
          ext = split[split.length - 1]
          return ext is 'html'
      css:
        src: [
          '<%= dist.css %>'
        ]
      assets:
        src: [
          '<%= dir.dist %>css/fonts/**'
          '<%= dir.dist %>img/'
          '<%= dir.dist %>favicon.ico'
        ]

    mkdir:
      tmp:
        options:
          create: [ 'dist/tmp' ]

    copy:
      mock:
        files: [
          src: [
            '<%= files.mock %>'
          ]
          dest: '<%= dir.dist %>'
          cwd: '.'
          expand: true
        ]
      meta:
        files: [
          src: [
            '<%= files.meta %>'
          ]
          dest: '<%= dir.dist %>'
          cwd: '.'
          expand: true
          flatten: true
        ]
      img:
        files: [
          src: [
            '<%= files.img %>'
          ]
          dest: '<%= dir.dist %>'
          cwd: '.'
          expand: true
        ]
      favicon:
        files: [
          src: [
            '<%= files.favicon %>'
          ]
          dest: '<%= dir.dist %>'
          cwd: '.'
          expand: true
          flatten: true
        ]
      vendor:
        expand: true
        cwd: '.'
        src: [
          '<%= files.vendor %>'
        ]
        dest: '<%= dir.dist %>'


    # compile coffeescript files
    coffee:
      server:
        options:
          bare: true
        expand: true
        cwd: '.'
        src: [
          '<%= files.server %>'
        ]
        dest: '<%= dir.dist %>'
        ext: '.js'
        filter: (filename) ->
          split = filename.split '.'
          ext = split[split.length - 1]
          return ext is 'coffee'
      client:
        options:
          bare: true
        expand: true
        cwd: '.'
        src: [
          '<%= files.client %>'
        ]
        dest: '<%= dir.dist %>'
        ext: '.js'
        filter: (filename) ->
          split = filename.split '.'
          ext = split[split.length - 1]
          return ext is 'coffee'

    # compile coffeecup
    coffeecup:
      views:
        expand: true
        cwd: '.'
        src: [
          '<%= files.html %>'
        ]
        dest: '<%= dir.dist %>'
        ext: '.html'

    # lint + minify CSS
    recess:
      app:
        src: [
          '<%= files.css %>'
        ]
        dest: '<%= dir.dist %>css/taylor.css'
        options:
          compile: true
          compress: false
          noUnderscores: false
          noIDs: false
          zeroUnits: false


    todos:
      src:
        options:
          priorities:
            low: /TODO/
            med: /FIXME/
            high: null
          reporter:
            header: () ->
              return '-- BEGIN TASK LIST --\n\n'
            fileTasks: (file, tasks, options) ->
              return '' if !tasks.length

              result = ''
              result += '* ' + file + '\n'

              tasks.forEach (task) ->
                result += '[' + task.lineNumber + ' - ' + task.priority +
                  ']' + task.line + '\n'

              result += '\n\n'
            footer: () ->
              return '-- END TASK LIST --\n'
        files:
          'TODO.md': [
            '<%= files.server %>'
            '<%= files.client %>'
            '<%= files.meta %>'
            '<%= files.html %>'
            '<%= files.css %>'
            '!TODO.md'
            '!Gruntfile.coffee'
          ]

    concat:
      client:
        options:
          stripBanners: true
          banner: '<%= meta %>'
        src: [
          '<%= files.clientTmp %>'
        ]
        dest: '<%= dist.client %>'
        filter: 'isFile'

    uglify:
      app:
        options:
          banner: '/* <%= meta %> '
        files:
          '<%= dir.dist %>js/taylor.min.js': [
            '<%= dist.client %>'
          ]

    # lint *.js files
    jshint:
      server:
        expand: true
        jshintrc: '.jshintrc'
        cwd: '<%= dir.dist %>'
        src: [
          '<%= files.server %>'
        ]
        filter: (filename) ->
          split = filename.split '.'
          ext = split[split.length - 1]
          return ext is 'js'

      client:
        jshintrc: '.jshintrc'
        src: [
          '<%= dir.dist %>assets/js/app.js'
          '<%= dir.dist %>assets/js/app.min.js'
        ]

    # lint *.coffee files
    coffeelint:
      gruntfile:
        files:
          src: [
            'Gruntfile.coffee'
          ]

      server:
        src: [
          '<%= files.server %>'
        ]
        filter: (filename) ->
          split = filename.split '.'
          ext = split[split.length - 1]
          return ext is 'coffee'

      client:
        src: [
          '<%= files.client %>'
        ]
        options:
          max_line_length:
            level: 'error'
            value: 500
        filter: (filename) ->
          split = filename.split '.'
          ext = split[split.length - 1]
          return ext is 'coffee'

  # merge, init config
  grunt.initConfig(grunt.util._.extend(taskConfig, fileConfig))

  grunt.registerTask 'default', [
    'concurrent:dev'
  ]

  grunt.registerTask 'build:server', [
    'clean:server'

    'coffeelint:server'
    'coffee:server'

    'copy:meta'
    'copy:mock'
    # 'jshint:server'
  ]

  grunt.registerTask 'build:client', [
    'clean:client'
    'clean:html'

    'coffeelint:client'
    'coffee:client'

    'coffeecup'

    'clean:tmp'
    'mkdir:tmp'
    # 'jshint:client'
  ]

  grunt.registerTask 'build:css', [
    'clean:css'

    'recess:app'
  ]

  grunt.registerTask 'build:assets', [
    'clean:assets'

    'copy:vendor'
    'copy:img'
    'copy:favicon'
  ]

  grunt.registerTask 'build', [
    'clean:tmp'
    'clean:dist'

    'todos'

    'build:server'
    'build:client'
    'build:css'
    'build:assets'

    'uglify'

    'clean:tmp'
    'mkdir:tmp'
  ]

  grunt.registerTask 'build:prod', [
    'build'

    'changelog'
    'bump'
  ]

  ###
  grunt.registerTask 'lint', [
    'jshint'
    'coffeelint'
  ]

  grunt.registerTask 'build:prod', [
    'lint'
    'clean:tmp'
    'clean:dist'
    'compile'
    'copy:meta'
    'copy:fonts'
    'copy:img'
    'copy:favicon'
    'concat:app'
    'concat:vendor'
    'recess:app'
    'recess:vendor'
    'clean:tmp'
    'changelog'
    'bump'
  ]
  ###
