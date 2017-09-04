// web/static/js/views/topic/show.js

/* global tinymce, tinyMCE */

import $ from 'jquery'
import List from 'list.js'
import socket from '../../socket'
import MainView from '../main';

export default class View extends MainView {

  constructor(){
    super()
    this.editMode = $('#topic').data('editmode')
    this.topic_id = $('#topic').data('id')
    this.selectedIdea = null
  }

  appendComments(idea){
    idea._values.comments.forEach(c => {
      $(`.idea[data-id=${idea._values.id}]`).children('.comments').append(`
        <li class="comment list-group-item" data-id="${c.id}">
          <strong>${c.user}: </strong>
          ${c.text}
          <div class='pl-2 pull-right'>
            <i>4 minutes ago</i>
            <button type="button" class="btn btn-light btn-sm">
              <i class="fa fa-trash" aria-hidden="true"></i>
            </button>
          </div>
        </li>
      `)
    })
  }

  mount() {
    super.mount();

    //######################### AlWAYS TO BE DONE ##############################

    // prepare the idea list
    var list_options = {
      item: 'idea-item',
      valueNames: [
        {data: ['id']},
        'title',
        'description',
        'user'
      ]
    }

    // create empty idea list
    var ideaList = new List('idea-list', list_options, [])

    // define and join topicChannel
    let channel = socket.channel(`topic:${this.topic_id}`)
    channel.join()
      // on load retrieve list of ideas from server
      .receive("ok", ({ideas}) => {

        // render a list of ideas
        ideaList.add( ideas, (ideas) => {
          // add comments to each item
          ideas.forEach((idea) => this.appendComments(idea))
        })
      })
      .receive("error", resp => { console.log("Unable to join", resp) })

    //###################### EDIT FUNCTIONALIY ONLY ############################

    if(this.editMode){

      // enable stripped TinyMCE for idea input
      tinymce.init({
        selector: '#idea_description',
        branding: false,
        height : 200,
        menubar: false,
        statusbar: false,
        plugins: [
          'advlist autolink lists link print preview',
          'searchreplace code fullscreen',
          'paste'
        ],
        toolbar: 'undo redo | bold italic | bullist numlist outdent indent | link',
      })

      // insert "add idea" and "instructions" buttons in menu
      $('#menu-actions').prepend(`
        <li class="nav-item mr-2">
          <button id="btn-add-idea" class="btn btn-success">
            <i class="fa fa-plus" aria-hidden="true"></i> Add Idea
          </button>
        </li>
        <li class="nav-item mr-2">
          <button class="btn btn-primary" data-toggle="modal" data-target="#modal-instructions">
            <i class="fa fa-info" aria-hidden="true"></i> Instructions
          </button>
        </li>
      `)

      // submit idea form (add or update)
      $('#submitIdea').submit((e) => {
        e.preventDefault()

        // ensure textinputs are submitted to form
        tinymce.triggerSave()

        // read form data
        let formData = {
          title       : $('#idea_title').val(),
          description : $('#idea_description').val(),
          idea_id     : this.selectedIdea,
          user_id     : $('#idea_user_id').val() || null
        }

        channel.push("submit-idea", formData)
          .receive("ok", i => {

            // check if idea already exists
            let idea = ideaList.get("id", i.id)[0]

            // add or update idea
            if(idea) idea.values(i)
            else ideaList.add(i)

            // close (and reset) idea form
            $('#modal-submit-idea').modal('hide')
          })

          // validation on error
          .receive("error", ({errors}) => {
            if (errors.title)
              $('#idea_title')
                .removeClass('is-valid')
                .addClass('is-invalid')
                .siblings('.invalid-feedback')
                .html(errors.title)
            else
              $('#idea_title')
                .addClass('is-valid')
                .removeClass('is-invalid')
                .siblings('.invalid-feedback')
                .html('')

            if (errors.description)
              $('#idea_description')
                .addClass('is-invalid')
                .removeClass('is-valid')
                .siblings('.invalid-feedback')
                .html(errors.description)
            else
              $('#idea_description')
                .addClass('is-valid')
                .removeClass('is-invalid')
                .siblings('.invalid-feedback')
                .html('')
          })
      })

      // click on add idea button
      $('nav').on('click', '#btn-add-idea', () => {
        $('#modal-submit-idea').modal('show').find('.modal-title').html('Add Idea')
      })


      // reset form when modal is being hidden
      $('#modal-submit-idea').on('hidden.bs.modal', function (e) {

        this.selectedIdea = null

        $('#idea_title, #idea_description')
          .removeClass('is-valid is-invalid')
          .val('')
          .siblings('.invalid-feedback').html('')
        tinymce.get('idea_description').setContent('');
      }.bind(this))
    }

    //###################### ADMIN FUNCTIONALIY ONLY ###########################
    if(this.admin){

      // click on edit idea button
      $('#idea-list').on('click', '.btn-edit-idea', (e) => {

        this.selectedIdea = $(e.target).closest('.idea').data('id')
        const idea = ideaList.get("id", this.selectedIdea)[0]._values

        // fill idea-form with data
        $('#idea_title').val(idea.title)
        tinymce.get('idea_description').setContent(idea.description);

        // open modal
        $('#modal-submit-idea').modal('show').find('.modal-title').html('Edit Idea')
      })

      // click on delete idea button
      $('#idea-list').on('click', '.btn-delete-idea', (e) => {
        this.selectedIdea = $(e.target).closest('.idea').data('id')
        $('#modal-delete').modal('show')
      })

      // delete idea
      $('#btn-delete-idea').click((e) => {
        channel.push("delete-idea", {idea: this.selectedIdea})
          .receive("ok", () => {
            // if deletion was successful, remove from list as well
            ideaList.remove("id", this.selectedIdea)
          })

        $('#modal-delete').modal('hide')
      })

      // reset selected idea upon closing delete confirm window
      $('#modal-delete')
        .on('hidden.bs.modal', function (e) { this.selectedIdea = null }.bind(this))
    }
  }

  unmount() {
    super.unmount();

  }

  renderIdea({id, title, description, user, comments}){

    $('#idea-container').prepend(`
    <div data-id="${id}" class="idea card mb-1">
      <div class="card-body">
        <h4 class="card-title">${title}</h4>
        <h6 class="card-subtitle mb-2 text-muted">${user.firstname} ${user.lastname}</h6>
        ${description}
        <ul class="comments list-group"></ul>
      </div>
    </div>
    `)

    if(window.editTopic) $(`.idea[data-id=${id}]`)
      .append('EDIT')
    // const commentList = comments.forEach( c => this.renderComment(c))
  }
}




//   $('#submit-idea').submit(e => {
//     e.preventDefault()

//     let payload = {
//       title: $('#idea_title').val(),
//       description: $('#idea_description').val(),
//       user_id: $('#idea_user_id').val()
//     }

//     topicChannel.push("new_idea", payload)
//       .receive("ok", (idea) => {
//         window.location.reload(true);
//       })
//       .receive("error", (data) => {

//         $("#idea_alert").removeClass('d-none')

//         if(data.errors.title)
//           $('#idea_title')
//             .addClass('is-invalid')
//             .siblings('.invalid-feedback').html(data.errors.title[0])
//         else
//           $('#idea_title').addClass('is-valid')

//         if(data.errors.description)
//           $('#idea_description')
//             .addClass('is-invalid')
//             .siblings('.invalid-feedback').html(data.errors.description[0])
//         else
//           $('#idea_title').addClass('is-valid')
//       })

//     $('#idea_title').val("")
//     $('#idea_description').val("")
//     $('#idea_user_id').val("")
//   })

//   $('.add-comment').submit((e) => {
//     e.preventDefault()

//     let payload = {
//       text: $(e.currentTarget).find('.comment-text').val(),
//       idea_id: $(e.currentTarget).find('.comment-idea').val()
//     }

//     topicChannel.push("new_comment", payload)
//       .receive("error", e => console.log(e) )
//     $('.comment-text').val("")
//   })

//   topicChannel.on("new_idea", (idea) => {
//     renderIdea(idea)
//   })


// }

// function esc(str){
//   let div = document.createElement("div")
//   div.appendChild(document.createTextNode(str))
//   return div.innerHTML
// }

// function renderIdea(idea){
//   // TODO append annotation to msgContainer
//   console.log(idea)

//   // let template = document.createElement("div")

//   // template.innerHTML = `
//   // <a href="#" data-seek="${this.esc(at)}">
//   //   <b>${this.esc(user.username)}</b>: ${this.esc(body)}
//   // </a>
//   // `
//   // msgContainer.appendChild(template)
//   // msgContainer.scrollTop = msgContainer.scrollHeight

// }
