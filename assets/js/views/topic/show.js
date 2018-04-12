// web/static/js/views/idea/index.js
/* global $ */
import socket from '../../app'
import MainView from '../main';

class View extends MainView {
  mount() {
    super.mount();

    this.comments  = $("#comments")
    this.feedback  = $("#feedback")

    this.idea = null
    this.editable = this.admin || (this.user && window.topic_open)

    // join topic channels
    this.config_topic_channel(window.topic_id)

    // differentiate add / edit idea modal
    $('#ideaModal').on('show.bs.modal', event => {
      const edit = $(event.relatedTarget).data('action') === 'update:idea'
      const data = edit
        ? this.idea
        : {
          title: '',
          desc: '',
          fake_rating: '',
          fake_raters: 0
        }
      // update modal with new data
      $(this).find('.modal-title').text(edit ? "Edit Idea" : "Add Idea")
      $('#idea_title').val(data.title)
      $('#idea_desc').val(data.desc)
      $('#idea_fake_rating').val(data.fake_rating)
      $('#idea_fake_raters').val(data.fake_raters)
      $('#idea-form').data('action', $(event.relatedTarget).data('action'))

      // remove all errors
      $('#ideaModal input, #ideaModal textarea').removeClass('is-valid is-invalid')
    })
  }

  config_topic_channel(id){
    this.topicChannel = socket.channel(`topic:${id}`, {})
    this.topicChannel.join()
    .receive("ok", resp => {
      let ids = resp.ideas.map(i => i.id)
      if(ids.length > 0) this.topicChannel.params.last_seen_id = Math.max(...ids)

      this.ideasTable = $('#ideas').DataTable({
        data: resp.ideas,
        columns: [
          { data: 'title', title: "Title" },
          { data: 'rating', title: "<i class='fas fa-star'></i>" },
          { data: 'comment_count', title: "<i class='far fa-comments'></i>" },
          { data: 'created', title: "<i class='far fa-clock mr-2'></i>",
            render: data => (`<small><time datetime='${data}'></time></small>`),
            width: 60
          }
        ],
        order: [[ 3, 'desc' ]],
        rowId: 'js_id',
        safeState: true,
        select: { style: 'single' }
      });

      this.ideasTable.on('select', ( e, dt, type, indexes ) => {

        const idea = this.ideasTable.rows( indexes ).data().toArray()[0];

        // join idea channel
        this.config_idea_channel(idea.id)

        this.ideasTable[ type ]( indexes ).nodes().to$().addClass('table-primary' );
        $('#no-idea').addClass('d-none');
        $('#idea h4').html(idea.title)
        if(idea.rating) $('#rating').removeClass('d-none')
        else $('#rating').addClass('d-none')
        $('#rating strong').html(idea.rating)
        $('#rating small span').html(idea.raters)
        if(idea.user_rating) $('#star'+idea.user_rating).attr('checked', true)
        if(idea.desc) $('#idea-desc').removeClass('d-none').html(idea.desc)
        else $('#idea-desc').addClass('d-none')

        $('#idea').removeClass('d-none');
        this.idea = idea
      })

      this.ideasTable.on('deselect', ( e, dt, type, indexes ) => {
        // leave idea channel
        this.idea = null;
        this.ideaChannel.leave()
        this.ideasTable[ type ]( indexes ).nodes().to$().removeClass('table-primary' );
        $('#no-idea').removeClass('d-none');
        $('#idea').addClass('d-none');
        this.comments.html(this.no_feedback_template())
      })

      $('#ideas time').timeago()
    })

    // Submit Add/Edit Idea Form
    $('#idea-form').on('submit', e => {
      e.preventDefault()
      const action = $('#idea-form').data('action')
      const data = {
        id: this.idea ? this.idea.id : null,
        title: $('#idea_title').val(),
        desc: $('#idea_desc').val(),
        fake_rating: $('#idea_fake_rating').val(),
        fake_raters: $('#idea_fake_raters').val()
      }
      this.topicChannel.push(action, data)
      .receive('ok', () => { $('#ideaModal').modal('hide')})
      .receive('error', (res) => {
        if(res.errors){
          $('#ideaModal input, #ideaModal textarea').addClass('is-valid')
          $('#ideaModal .invalid-feedback').text('')
          $.each( res.errors, (field, error) => {
            console.log(field)
            $('#idea_'+field).removeClass('is-valid').addClass('is-invalid')
            .siblings('.invalid-feedback').text(error)
          })
        }
      })
    })

    // Response to broadcast event "new:idea"
    this.topicChannel.on("new:idea", idea => {
      this.topicChannel.params.last_seen_id = idea.id
      this.ideasTable.row.add( idea ).draw().node();
      $('#ideas time').timeago()
    })

    // Response to broadcast event "update:idea"
    this.topicChannel.on("update:idea", idea => {
      this.ideasTable.row(`#idea_${idea.id}`).data(idea).draw();
      $('#ideas time').timeago()
    })
  }

  config_idea_channel(id){

    this.ideaChannel = socket.channel(`idea:${id}`, {})
    this.ideaChannel.join()
    .receive("ok", resp => {
      let ids = resp.comments.map(c => c.id)
      if(ids.length > 0) this.ideaChannel.params.last_seen_id = Math.max(...ids)

      if(resp.comments.length > 0) $('#no_feedback').remove()
      resp.comments.forEach(c => this.comments.append(this.messageTemplate(c)))
    })
    .receive("error", reason => console.log("join failed", reason) )

    this.feedback.off("keypress").on("keypress", e => {
      if (e.keyCode == 13) {
        this.ideaChannel.push("new:feedback", { text: this.feedback.val()} )
        .receive('ok', () => { this.feedback.val("").removeClass('is-invalid')})
        .receive('error', (res) => { console.log(res.reason);  this.feedback.addClass('is-invalid') })
      }
    })

    this.ideaChannel.on("new:feedback", feedback => {
      this.ideaChannel.params.last_seen_id = feedback.id
      this.comments.append(this.messageTemplate(feedback))
      $('#no_feedback').hide()
      $('#comments time').timeago()
      scrollTo(0, document.body.scrollHeight)
    })

    this.ideaChannel.on("delete:feedback", ({id}) => {
      $(`#comments li[data-id=${id}]`).remove()
    })

    if(window.admin){
      // Delete Feedback
      $('#comments').on('click', 'a.delete', e => { console.log(e)
        this.ideaChannel.push("delete:feedback", {
          id: $(e.currentTarget).closest('li').data('id')})
      })
    }

    $('#comments').on('click', 'a.like', e => {
      const elm = $(e.target)
      const comment = elm.closest('li').data('id')
      let likes = parseInt(elm.siblings('.likes').html(), 10)

      if( elm.html().trim() === "Like" ) {
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

    $('#comments').on('focus', 'input.fake-ratings', e => { e.target.select() })
    $('#comments').on('change', 'input.fake-ratings', e => {
      const comment = $(e.target).closest('li').data('id')
      const fake_likes = $(e.target).val()
      this.ideaChannel.push("update:fake_likes", { comment, fake_likes })
    })

    // clicking on rating icon should trigger rating
    $('#rate').on('change', 'input', e => {
      this.ideaChannel.push("rate", { rating : e.target.value })
    })
  }

  sanitize(html){ return $("<div/>").text(html).html() }

  messageTemplate(comment){


    const thumbsup = window.admin || (window.user && window.topic_open)
      ? `<i class="far fa-thumbs-up text-primary"></i>` : ``

    const like_btn = window.admin || (window.user && window.topic_open)
      ? `<a class="like text-primary pointer">Like</a>` : ``

    const hidden = comment.likes === 0 ? `d-none` : ``

    const administrate = window.admin
      ? `<span class="float-right">
          <small class="text-muted font-italic">
            Fake Likes:
            <input type="number" class="fake-ratings text-primary" value="${comment.fake_likes}" />
            <a class="delete pointer">
              <i class="text-danger fas fa-trash-alt"></i>
            </a>
          </small>
        </span>`
      : ``;

    return(`
      <li class="list-group-item px-2 py-1" data-id="${comment.id}">
        <small class="ml-1 float-right font-italic text-muted">
          <time datetime="${comment.time}Z"></time>
        </small>
        <strong>${comment.author}</strong><br>
        ${this.sanitize(comment.text)}<br>
        <span>
          ${thumbsup}
          <div class="likes badge badge-primary ${hidden}">${comment.likes}</div>
          ${like_btn}
          ${administrate}
        </span>
      </li>
    `)
  }

  no_feedback_template(){
    return (`
      <li id="no_feedback" class="list-group-item px-2 py-1 font-italic text-center">
        no feedback yet...
      </li>
    `)
  }

  unmount() {
    super.unmount();
    $('#ideas').DataTable().destroy()
    this.topicChannel.leave()
    if(this.ideaChannel) this.ideaChannel.leave()
  }
}

export default View