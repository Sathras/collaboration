// Import dependencies
/* global $ */
import { Socket } from "phoenix"
import "phoenix_html"
import Turbolinks from "turbolinks"

// Import local files
import { setTimeagoStrings } from './utils/functions';
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

// set timeago local stings
setTimeagoStrings()

// initialize TurboLinks
Turbolinks.start()

// connect socket
const socket = new Socket("/socket", { params: { token: $('meta[name="token"]').attr("content") }})
socket.connect()
export default socket