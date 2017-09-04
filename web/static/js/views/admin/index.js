// web/static/js/views/admin/topics.js

// import jquery from 'jquery'
import $ from 'jquery'
import _ from 'lodash'
import List from 'list.js'
import MainView from '../main'

// create channel for socket
import socket from '../../socket'
const channel = socket.channel("admin")

export default class View extends MainView {

  addLinks(table, items){
    return _.map(items, (i) => {
      return _.assign(i, {
        deleteLink: `/${table}/${i.id}/delete`,
        editLink: `/${table}/${i.id}/edit`,
        link: `/${table}/${i.id}`
      })
    })
  }

  mount() {
    super.mount();

    // prepare the topic list
    let topic_list_options = {
      item: "topicsItem",
      valueNames: [
        {data: ['id']},
        'order',
        'title',
        { name: 'closed', attr: 'data-value' },
        { name: 'hidden', attr: 'data-value' },
        { name: 'link', attr: 'href' },
        { name: 'editLink', attr: 'href' },
        { name: 'deleteLink', attr: 'href' },
      ]
    }

    // prepare the user list
    let user_list_options = {
      item: "usersItem",
      valueNames: [
        {data: ['id']},
        'email',
        'username',
        'firstname',
        'lastname',
        { name: 'admin', attr: 'data-value' },
        { name: 'faux', attr: 'data-value' },
        { name: 'link', attr: 'href' },
        { name: 'editLink', attr: 'href' },
        { name: 'deleteLink', attr: 'href' },
      ]
    }

    // create empty topic list
    let topicList = new List("topicsList", topic_list_options, [])
    let userList = new List("usersList", user_list_options, [])

    // join admin channel and load all topics and users
    channel.join()
      .receive("ok", ({ topics, users }) => {

        topics = this.addLinks('topics', topics)
        users = this.addLinks('users', users)

        // render and sort a list of topics
        topicList.add( topics )
        topicList.sort('order', { order: "asc" })

        // render and sort a list of users
        userList.add( users )
        userList.sort('username', { order: "asc" })
      })
      .receive("error", res => console.log(res))

    // Enable TinyMCE for textarea fields
    tinymce.init({
      selector: '#instructions-input',
      height: 500,
      branding: false,
      height : 200,
      menubar: false,
      plugins: [
        'advlist autolink lists link image charmap print preview anchor',
        'searchreplace visualblocks code fullscreen',
        'insertdatetime media table contextmenu paste code'
      ],
      toolbar: 'undo redo | insert | styleselect | bold italic | alignleft aligncenter alignright alignjustify | bullist numlist outdent indent | link image',
      setup:function(ed) {
        // changing the field should unlock the submit button
        ed.on('change', function(e) {
          $('#instructions-button')
            .removeClass('btn-secondary btn-success disabled')
            .addClass('btn-primary')
            .html('Save')
        })
      }
    })

    // server feedback for toggling boolean variables in any table
    channel.on('toggle', ({id, table, field}) => {
      let item = null
      if(table === 'topic') item = topicList.get("id", id)[0]
      else if (table === 'user') item = userList.get("id", id)[0]
      if(item) item.values({[field]: !item._values[field]})
    })

    // server feedback for toggling boolean variables in any table
    channel.on('update-data', ({ field, value }) => {
      if(field === 'instructions'){
        $('#instructions-button')
          .removeClass('btn-primary btn-secondary')
          .addClass('btn-success disabled')
          .html('Updated')
        $('#modal-instructions modal-body').html(value)
      }
    })

    // allow for enabling / disabling toggle features
    $('.list').on('click', '.toggle', (e) =>{
      channel.push('toggle', {
        id :   $(e.target).parent().parent().data('id'),
        table: $(e.target).parent().parent().attr('class'),
        field: $(e.target).parent().attr('class')
      })
    })

    // submitting update instructions
    $('#instructions-form').submit((e) =>{
      e.preventDefault()
      $('#instructions-button').addClass('disabled').html('processing...')
      channel.push('update-data', {
        field: 'instructions',
        value: $('#instructions-form textarea').val()
      })
    })
  }

  unmount() {
    super.unmount();

  }
}
