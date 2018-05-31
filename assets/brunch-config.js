exports.config = {
  // See http://brunch.io/#documentation for docs.
  files: {
    javascripts: {
      joinTo: "js/app.js"
    },
    stylesheets: {
      joinTo: "css/app.css",
      order: {
        after: ["priv/static/css/app.css"] // concat app.css last
      }
    },
    templates: {
      joinTo: "js/app.js"
    }
  },

  conventions: {
    // This option sets where we should place non-css and non-js assets in.
    // By default, we set this to "/assets/static". Files in this directory
    // will be copied to `paths.public`, which is "priv/static" by default.
    assets: /^(static)/
  },

  // Phoenix paths configuration
  paths: {
    // Dependencies and current project directories to watch
    watched: ["static", "css", "js"],
    // Where to compile files to
    public: "../priv/static"
  },

  // Configure your plugins
  plugins: {
    babel: {
      presets: ['env', 'stage-2']
    },
    beforeBrunch: [
      'prettier --loglevel warn --single-quote --write "{js,css}/**/*"'
    ]
  },

  modules: {
    autoRequire: {
      "js/app.js": ["js/app"]
    }
  },

  npm: {
    enabled: true,
    globals: { // Bootstrap requires both '$' and 'jQuery' in global scope
      $: 'jquery',
      jQuery: 'jquery',
      bootstrap: 'bootstrap'
    },
    styles: {
      'bootstrap': ['dist/css/bootstrap.css']
    }
  }
};
