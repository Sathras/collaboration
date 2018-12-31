// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import "../node_modules/bootstrap/dist/css/bootstrap.min.css"
import css from "../css/app.css"

// webpack automatically bundles all modules in your
// entry points. Those entry points can be configured
// in "webpack.config.js".

// Import dependencies

require("expose-loader?$!jquery")
import 'phoenix_html'
import Turbolinks from 'turbolinks'

// Import local files
import './socket'
import { configTimeago } from './utils/functions'
import loadView from './views/loader'

function handleDOMContentLoaded(event) {
  // Load view class and mount it
  const ViewClass = loadView($('body').data('js-view-name'))
  const view = new ViewClass()
  view.mount()
  window.currentView = view

  // google analytics tracking
  if (typeof ga === 'function') {
    ga('set', 'location', event.data.url)
    ga('send', 'pageview')
  }
}

function handleDocumentUnload() {
  window.currentView.unmount()
}

// ALL FOLLOWING FUNCTIONS WILL BE EXECUTED ONLY ONCE (ON THE INITIAL PAGE LOAD)

// Configuration
configTimeago();

// initialize TurboLinks
document.addEventListener('turbolinks:load', handleDOMContentLoaded)
document.addEventListener('turbolinks:before-visit', handleDocumentUnload)
Turbolinks.start()

window.__socket = require("phoenix").Socket
