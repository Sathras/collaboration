import $ from 'jquery'
import MainView from '../main'

import socket from '../../utils/socket'
import { debug } from '../../utils/functions'

export default class View extends MainView {

  checkReload() {
    // reloads page every 30 seconds unless currently focusing on an input
    if(!this.writeFocus) location.reload(true);
  }

  joinChannel(){

    // since we only use socket in this view no need to connect socket before
    socket.connect()

    const channel = socket.channel("topic")
    this.channel = channel

    // join and schedule loading of future ideas, comments, likes, and ratings
    channel.join().receive('ok', ({ ideas, comments, ratings, condition, remaining, started }) => {

      // Debug some information if experiment user and env=dev
      if(condition > 0){

        const rtext = (remaining > 0) ? ` and will finish in ${remaining} seconds` : ``
        debug(`Experiment started ${started} seconds ago${rtext}. User condition: ${condition}`)

        // enable "finish" button, if experiment is done
        setTimeout(() => {
          debug(`Experiment Timer ran out. Enabling finish button.`)
          $('#timer').addClass('d-none')
          $('#btn-complete').removeClass('d-none')
        }, Math.max(0, remaining * 1000))
      }
    })
  }

  safeScrollPos(){
    localStorage.setItem('scroll-pos', $(window).scrollTop())
  }

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
      // elm.removeClass('is-invalid')
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

    if(reload_in > 0){
      console.log(`reloading in ${reload_in/1000} seconds...`)
      setTimeout(() => { if(!this.focus) this.reload() }, reload_in)
    }



    // Disable Spinner
    $('#spinner-wrapper').hide()
  }

  unmount() {
    super.unmount();
    $('#timer').remove();
    $('#btn-complete').remove();
  }
}
