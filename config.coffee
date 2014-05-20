exports.config =
  # See docs at http://brunch.readthedocs.org/en/latest/config.html.
  modules:
    definition: false
    wrapper: false
  paths:
    public: '_public'
  files:
    javascripts:
      joinTo:
        'js/app.js': /^app/
        'js/vendor.js': /^(bower_components|vendor)/

    stylesheets:
      joinTo:
        'css/app.css': /^(app|vendor|bower_components)/

  plugins:
    jaded:
      staticPatterns: /^app(\/|\\)(.+)\.jade$/
      jade:
        pretty: yes

  # Enable or disable minifying of result js / css files.
  minify: true
