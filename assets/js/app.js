/* global $ */
import 'phoenix_html';
import Turbolinks from 'turbolinks';

// import datatables
require('datatables.net-bs4')(window, $);
require('datatables.net-fixedheader')();
require('datatables.net-responsive-bs4')();
// require('datatables.net-scroller-bs4')();
// require('datatables.net-select-bs4')();

// Import local files
import { configPublicChannel } from './socket';
import { configTimeago } from './utils/functions';
import loadView from './views/loader';

function handleDOMContentLoaded() {
  // Load view class and mount it
  const ViewClass = loadView($('body').data('js-view-name'));
  const view = new ViewClass();
  view.mount();

  window.currentView = view;
}

function handleDocumentUnload() {
  window.currentView.unmount();
}

// ALL FOLLOWING FUNCTIONS WILL BE EXECUTED ONLY ONCE (ON THE INITIAL PAGE LOAD)

// Configuration
configTimeago();
configPublicChannel();

// initialize TurboLinks
document.addEventListener('turbolinks:load', handleDOMContentLoaded);
document.addEventListener('turbolinks:before-visit', handleDocumentUnload);
Turbolinks.start();
