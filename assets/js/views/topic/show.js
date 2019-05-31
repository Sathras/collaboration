import $ from 'jquery'
import MainView from '../main'

export default class View extends MainView {

  /**
   * When typing a comment:
   * 1) submit form on check for an enter (not shift + enter)
   * 2) automatically resize textarea
   * 3) auto-enable and disable error message
   **/
  type_comment(e){
    const elm = $(e.target)

    if(e.which == 13 && !e.shiftKey){
      elm.val(elm.val().slice(0, -1))
      elm.parent().submit()
    } else {
      e.target.style.height = '30px';
      e.target.style.height = e.target.scrollHeight + 'px';
    }
  }

  mount() {

    super.mount();

    this.focus = false

    // safe scroll position on form submissions
    document.body.addEventListener("phoenix.link.click", this.safeScrollPos)
    document.body.addEventListener("submit", this.safeScrollPos)

    // prevent page from automatically  reloading if writing idea
    $('#idea_text').keyup(e => { this.focus = true })

    // posting comments: resize field on keystroke and submit on ENTER, also prevent reloading
    $('#ideas').on('keyup', 'textarea', e => {
      this.focus = true
      this.type_comment(e)
    })

    // toggles star rating for submitting a user rating
    $("body").on('click', '.user-rating', (e) => {
      $(e.currentTarget).siblings().toggle()
    })

    // reload page after server-determined amount of milliseconds.
    // reload only, if not currently focusing on a textarea.
    const reload_in = $('body').data('reload-in')
    if(reload_in > 0) setTimeout(() => { if(!this.focus) this.reload() }, reload_in * 1000)
  }

  unmount() {
    super.unmount();
    $('#timer').remove();
    $('#btn-complete').remove();
  }
}
