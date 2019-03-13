import $ from 'jquery'
import 'timeago'
import 'bootstrap'

export default class MainView {

  // This will be executed whenever a new page is loaded
  mount() {

    // scroll back to previous scroll position on page load
    const pos = localStorage.getItem('scroll-pos', 0);
    if (pos) $(window).scrollTop(pos)

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
    // tinymce.init({
    //   mode: 'none',
    //   branding: false,
    //   menubar: false,
    //   statusbar: false,
    //   toolbar: `styleselect forecolor | indent outdent | hr | bullist numlist | link unlink | image table | preview code_toggle fullscreen`,
    //   plugins: `hr link lists image fullscreen preview textcolor table`,
    //   external_plugins: {
    //     // code_toggle: '/js/utils/tinymce-ace-editor.js'
    //   },
    //   style_formats: [
    //     {
    //       title: 'Image Left',
    //       selector: 'img',
    //       styles: {
    //         float: 'left',
    //         margin: '0 10px 0 10px'
    //       }
    //     },
    //     {
    //       title: 'Image Right',
    //       selector: 'img',
    //       styles: {
    //         float: 'right',
    //         margin: '0 0 10px 10px'
    //       },
    //       theme: 'modern'
    //     }
    //   ],
    //   style_formats_merge: true
    // });

    // enable form validation removal on change
    $('.form-control').change((e) => {
      $(e.target)
        .removeClass('is-valid is-invalid')
        .siblings('.invalid-feedback').remove();
    });
  }

  unmount() {
    // This will be executed when the document unloads...

    // reset scroll position
    localStorage.setItem('scroll-pos', 0);

    clearInterval(this.timer);
    $( ".form-control" ).off();
  }
}
