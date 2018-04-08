// web/static/js/views/main.js
/* global $, tinymce */
import "timeago"

export default class MainView {
  mount() {
    // This will be executed when the document loads...

    // enable tooltips
    $('[data-toggle="tooltip"]').tooltip()
    $('[data-toggle="popover"]').popover()

    $("time").timeago();

    // enable base tinyMCE instance
    tinymce.init({
  		mode : "none",
  		branding: false,
      menubar: false,
      statusbar: false,
      toolbar: `styleselect forecolor | indent outdent | hr | bullist numlist | link unlink | image table | preview fullscreen`,
      plugins: `hr link lists image fullscreen preview textcolor table`
    });

    $("#spinner-wrapper").addClass("invisible")
  }

  unmount() {
    // This will be executed when the document unloads...
    $("#spinner-wrapper").removeClass("invisible")
  }
}