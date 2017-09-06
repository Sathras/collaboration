// web/static/js/views/topic/show.js

/* global tinymce, tinyMCE */

import $ from 'jquery'
import _ from 'lodash'
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

    // empty all comments before redrawing
    const commentList = $(`#idea-list .idea[data-id=${idea._values.id}] .comments`)
    commentList.html('')

    const admin_functions = (this.admin)
      ? ` <button type="button" class="delete-comment btn btn-outline-dark btn-sm">
            <i class="fa fa-trash" aria-hidden="true"></i>
          </button>`
      : ``

    idea._values.comments.forEach(c => {

      const like_button = (this.editMode)
        ? ` <button type="button" class="btn-like btn btn-sm btn-outline-primary">
              ${(c.likes.indexOf(this.user_id) != -1) ? "Unlike" :  "Like"}
            </button>`
        : ``

      const likes = (c.likes.length)
        ? ` <span class="likes text-primary">
              <i class="fa fa-thumbs-o-up" aria-hidden="true"></i>
              <strong>${c.likes.length}</strong>
            </span>`
        : ``

      commentList.append(`
        <li class="comment list-group-item" data-id="${c.id}">
          <strong>${c.user} </strong>
          ${c.text}
          <span class="ml-2">
            ${likes}
            ${like_button}
          </span>
          <div class='pl-2 pull-right'>
            <i><time datetime="${c.inserted_at}"></time></i>
            ${admin_functions}
          </div>
        </li>
      `)
    })

    $('time').timeago()
  }

  updateComment (comments, newComment, id = null) {
    var match = _.find(comments, ['id', id])
    if(match){
      var index = _.indexOf(comments, _.find(comments, ['id', id]))
      comments.splice(index, 1, newComment)
    }
    else comments.push(newComment);
  }

  mount() {
    super.mount();

    //######################### AlWAYS TO BE DONE ##############################

    // prepare the idea list
    var list_options = {
      item: 'idea-item',
      valueNames: [
        {data: ['id']},
        {name: 'inserted_at', attr: 'datetime'},
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
      .receive("ok", ({ideas}) => ideaList.add(ideas))
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

      // COMMENTS

      // add comments to list entries once list has been updated
      ideaList.on('updated', ()=>{
        ideaList.items.forEach((idea) => this.appendComments(idea))
      })

      // submit idea form (add or update)
      $('#idea-list').on('submit', '.submitComment', (e, admin=this.admin) => {
        e.preventDefault()

        // read form data
        const idea_id = $(e.target).closest('.idea').data('id')
        let formData = {
          idea_id: idea_id,
          text : $(e.target).find('input').val()
        }
        if(admin) formData.user_id = $(e.target).find('select').val()

        channel.push("submit-comment", formData)
          .receive("ok", c => {
            // add comment to list object
            let idea = ideaList.get("id", idea_id)[0]
            let comments = idea._values.comments
            comments.push(c)
            idea.values({comments: comments})
            ideaList.update()
            $(e.target).find('input').val('').removeClass('is-invalid')
          })

          // validation on error
          .receive("error", ({errors}) => {
            if (errors.text)
              $(e.target).find('input').addClass('is-invalid')
          })
      })

      // like-button (toggles like for user)
      $('#idea-list').on('click', '.btn-like', (e, user_id=this.user_id) => {

        const idea_id = $(e.target).closest('.idea').data('id')
        const comment_id = $(e.target).closest('.comment').data('id')

        channel.push("toggle-like", {comment_id})
          .receive("ok", (c) => {

            let idea = ideaList.get("id", idea_id)[0]

            // find correct comment and update it
            let comments = _.assign(idea._values.comments)

            const i = _.findIndex(comments, (c) => { return c.id == comment_id })
            const j = comments[i].likes.indexOf(user_id)

            // add or remove like
            if (j == -1) comments[i].likes.push(user_id)
            else _.pullAt(comments[i].likes, [j])

            idea.values({comments: comments})
            ideaList.update()
          })
      })

      // enable comments
      $('.submitComment').find('input, button, select').removeAttr('disabled')

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

      // delete comment
      $('#idea-list').on('click', '.delete-comment', (e) => {
        const idea_id = $(e.target).closest('.idea').data('id')
        const comment_id = $(e.target).closest('.comment').data('id')
        channel.push("delete-comment", {comment_id})
          .receive("ok", () => {
            // if deletion was successful, remove from list as well
            let idea = ideaList.get("id", idea_id)[0]
            idea.values({comments: _.remove(idea._values.comments, (c) => {
              return c.id == comment_id;
            })})
            ideaList.update()
          })
      })
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
