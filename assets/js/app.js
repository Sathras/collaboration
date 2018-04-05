// Import dependencies
/* global $ */
import "phoenix_html"
import Turbolinks from "turbolinks"

// Import local files
import loadView from './views/loader';

function handleDOMContentLoaded() {
  // Get the current view name
  const viewName = $('body').data('js-view-name');

  // Load view class and mount it
  const ViewClass = loadView(viewName);
  const view = new ViewClass();
  view.mount();

  window.currentView = view;
}

function handleDocumentUnload() {
  window.currentView.unmount();
}

document.addEventListener("turbolinks:load", handleDOMContentLoaded)
document.addEventListener("turbolinks:before-visit", handleDocumentUnload)

// initialize TurboLinks
Turbolinks.start()
