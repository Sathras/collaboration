// web/static/js/views/main.js

/* global tinymce */
import $ from 'jquery'
import _ from 'lodash'
import List from 'list.js'
import timeago from 'timeago'

// create channel for socket
import socket from '../socket'
const channel = socket.channel("public")

export default class MainView {

  constructor(){
    this.admin   = $('body').data('admin')
    this.user_id = $('body').data('user_id')
  }

  // This will be executed when the document loads...
  mount() {

    // get userid

    // enable TimeAgo for all time elements with class timeago
    $("time.timeago").timeago()

    // Enable general TinyMCE for textarea fields
    tinymce.init({
      selector: 'textarea.tinyMCE',
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
    })

    // prepare the menu list
    const menu_list_options = {
      valueNames: [
        {data: ['id', 'order']},
        'menutitle',
        { name: 'link', attr: 'href' }
      ]
    }

    // create menuLink list
    let menuList = new List("menuList", menu_list_options)

    // highlight current list entry
    $('#menuList .nav-item > a.nav-link').each(function() {
      if($(this).attr('href') === $('body').data('path'))
      $(this).parent().addClass('active')
    });

    // join public channel
    channel.join()

    // server feedback for toggling boolean variables in any table
    channel.on('menutopic-show', (menulink) => {
      menulink = _.assign(menulink, { link: `/topics/${menulink.id}` })
      menuList.add(menulink)
      menuList.sort('order', { order: "asc" })
    })

    channel.on('menutopic-hide', ({id, menutitle, order}) => {
      menuList.remove("id", id)
    })
  }

  // This will be executed when the document unloads...
  unmount() {

  }
}