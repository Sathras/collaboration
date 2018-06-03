/* global $, tinymce */
import 'timeago';

export default class MainView {
  mount() {
    // This will be executed when the document loads...

    // enable tooltips
    $('[data-toggle="tooltip"]').tooltip();
    $('#nav-topics a').popover({
      container: 'body',
      html: true,
      placement: 'bottom',
      trigger: 'hover'
    });

    $('time').timeago();

    // enable base tinyMCE instance
    tinymce.init({
      mode: 'none',
      branding: false,
      menubar: false,
      statusbar: false,
      toolbar: `styleselect forecolor | indent outdent | hr | bullist numlist | link unlink | image table | preview code_toggle fullscreen`,
      plugins: `hr link lists image fullscreen preview textcolor table`,
      external_plugins: {
        // code_toggle: '/js/utils/tinymce-ace-editor.js'
      },
      style_formats: [
        {
          title: 'Image Left',
          selector: 'img',
          styles: {
            float: 'left',
            margin: '0 10px 0 10px'
          }
        },
        {
          title: 'Image Right',
          selector: 'img',
          styles: {
            float: 'right',
            margin: '0 0 10px 10px'
          },
          theme: 'modern'
        }
      ],
      style_formats_merge: true
    });
  }

  unmount() {
    // This will be executed when the document unloads...
  }
}
