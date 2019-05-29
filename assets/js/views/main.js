import $ from 'jquery'
import 'timeago'
import 'bootstrap'

export default class MainView {

  // reload page preserving scroll position and preventing the creation of a new history entry
  // https://github.com/turbolinks/turbolinks/issues/329#issuecomment-341699031
  reload() {
    localStorage.setItem('scroll-pos', $(window).scrollTop());
    Turbolinks.visit(window.location, { action: 'replace' })
  }

  // This will be executed whenever a new page is loaded
  mount() {

    // load saved scroll position and reset
    const pos = localStorage.getItem('scroll-pos');
    if (pos){
      $(window).scrollTop(pos)
      localStorage.removeItem('scroll-pos');
    }

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

    // enable form validation removal on change for all bootstrap input fields
    $('body').on('keyup', '.form-control', (e) => {
      $(e.target)
        .removeClass('is-valid is-invalid')
        .siblings('.invalid-feedback').remove();
    });
  }

  unmount() {
    // This will be executed when the document unloads...

    clearInterval(this.timer);
    $('body').off();
  }
}
