import $ from 'jquery'
import 'timeago'
import 'bootstrap'

export default class MainView {

  safeScrollPos(){
    localStorage.setItem('scroll-pos', $(window).scrollTop())
  }

  // reload page preserving scroll position and preventing the creation of a new history entry
  // https://github.com/turbolinks/turbolinks/issues/329#issuecomment-341699031
  reload() {
    this.safeScrollPos()
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

    // enable timeago
    $('time').timeago();

    // enable form validation removal on change for all bootstrap input fields
    $('body').on('keyup', '.form-control', (e) => {
      $(e.target)
        .removeClass('is-valid is-invalid')
        .siblings('.invalid-feedback').remove();
    });
  }

  unmount() {
    // This will be executed when the document unloads...
    $('body').off();
  }
}
