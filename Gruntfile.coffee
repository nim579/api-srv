module.exports = (grunt)->

    # Project configuration.
    grunt.initConfig
        coffee:
            app:
                options:
                    bare: true

                files: [
                    expand: true
                    cwd: './src/'
                    src: ['**/*.coffee']
                    dest: './lib/'
                    ext: '.js'
                ]

        watch:
            coffee:
                files: ['./src/**/*.coffee']
                tasks: ['coffee:app']

    grunt.loadNpmTasks 'grunt-contrib-coffee'
    grunt.loadNpmTasks 'grunt-contrib-watch'
