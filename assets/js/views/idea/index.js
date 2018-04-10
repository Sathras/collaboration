// web/static/js/views/idea/index.js
/* global $, Turbolinks */
import socket from '../../app'
import MainView from '../main';

export default class View extends MainView {
  mount() {
    super.mount();

    this.admin = $('body').data('admin')

    // join channel
    // const topic_id = $('body').data('topic_id')
    const idea = $('body').data('id') || null
    if(idea) this.config_idea_channel(idea)

    // order ideas by date
    $('#ideas').DataTable({"order": [[ 3, 'desc' ]]});

    // clicking on idea should open page with comments
    $('#ideas').on('click', 'tbody tr', e =>
      Turbolinks.visit($(e.currentTarget).data('path')))

    // show a specific modal if invalid formdata was submitted
    let show = $('#submitIdeaModal').data('show') ? 'show' : 'hide'
    $('#submitIdeaModal').modal(show)
    show = $('#editIdeaModal').data('show') ? 'show' : 'hide'
    $('#editIdeaModal').modal(show)



  }

  config_idea_channel(id){


    this.messages  = $("#comments")
    this.feedback  = $("#feedback")

    this.ideaChannel = socket.channel(`idea:${id}`, {})
    this.ideaChannel.join()

    this.feedback.off("keypress").on("keypress", e => {
      if (e.keyCode == 13) {
        this.ideaChannel.push("new:feedback", { text: this.feedback.val()} )
        .receive('ok', () => { this.feedback.val("").removeClass('is-invalid')})
        .receive('error', (res) => { console.log(res.reason);  this.feedback.addClass('is-invalid') })
      }
    })

    this.ideaChannel.on("new:feedback", payload => {
      this.messages.append(this.messageTemplate(payload))
      $('#no_feedback').hide()
      $('#comments time').timeago()
      scrollTo(0, document.body.scrollHeight)
    })

    this.ideaChannel.on("delete:feedback", ({id}) => {
      $(`#comments li[data-id=${id}]`).remove()
    })

    if(this.admin){
      $('#comments').on('click', 'a.delete-comment', e => {
        this.ideaChannel.push("delete:feedback", {
          id: $(e.currentTarget).closest('li').data('id')})
      })
    }

    $('#comments').on('click', 'a.like', e => {
      const elm = $(e.target)
      const comment = elm.closest('li').data('id')
      let likes = parseInt(elm.siblings('.likes').html(), 10)

      if( elm.html() === "Like" ) {
        this.ideaChannel.push("like:feedback", { comment })
        .receive('ok', () => {
          likes++
          elm.html('Unlike')
          elm.siblings('.likes').removeClass('d-none').html(likes)
        })
      } else {
        this.ideaChannel.push("unlike:feedback", { comment })
        .receive('ok', () => {
          likes--
          elm.html('Like')
          elm.siblings('.likes').html(likes)
          if(!likes) elm.siblings('.likes').addClass('d-none')
        })
      }
    })

    // clicking on rating icon should trigger rating
    $('#rate').on('change', 'input', e => {
      this.ideaChannel.push("rate", { rating : e.target.value })
    })
  }

  sanitize(html){ return $("<div/>").text(html).html() }

  messageTemplate(comment){
    const deleteLink = this.admin
      ? `<a class="delete-comment pointer">
           <i class="text-danger fas fa-trash-alt"></i>
         </a>`
      : ``;

    return(`
      <li class="list-group-item px-2 py-1" data-id="${comment.id}">
        <small class="ml-1 float-right font-italic text-muted">
          <time datetime="${comment.time}Z"></time>
          ${deleteLink}
        </small>
        <strong>${comment.author}</strong>
        ${this.sanitize(comment.text)}
      </li>
    `)
  }

  unmount() {
    super.unmount();
    $('#ideas').DataTable().destroy()
    if(this.ideaChannel) this.ideaChannel.leave()
  }
}