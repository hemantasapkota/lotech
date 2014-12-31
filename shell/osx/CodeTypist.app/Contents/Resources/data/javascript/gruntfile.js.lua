return [=[
'use strict';

module.exports = function (grunt) {
  require('load-grunt-tasks')(grunt);
    grunt.initConfig({
        karma: {
          unit: {
            configFile: 'karma.conf.js',
            singleRun: true
          }
        },
        jshint: {
          options: {
            jshintrc: '.jshintrc'
          },
          all: [
            'Gruntfile.js',
            'angular-spinner.js',
            'tests.js',
            'karma.conf.js'
          ]
        },
        uglify: {
          dist: {
            options: {
              sourceMap: true
            },
            files: {
              'angular-spinner.min.js': 'angular-spinner.js'
            }
          }
        }
  });

  grunt.registerTask('test', [
    'jshint',
    'karma'
  ]);

  grunt.registerTask('build', [
    'uglify'
  ]);

  grunt.registerTask('default', ['build']);
};
]=]
