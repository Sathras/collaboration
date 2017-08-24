// web/static/js/views/main.js

/* global tinymce */
import $ from 'jquery'
import timeago from 'timeago'

export default class MainView {
  // This will be executed when the document loads...
  mount() {

    // enable TimeAgo for all time elements with class timeago
    $("time.timeago").timeago()

    // Enable TinyMCE for textarea fields
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
      // content_css: [
      //   '//fonts.googleapis.com/css?family=Lato:300,300i,400,400i',
      //   '//www.tinymce.com/css/codepen.min.css']
    })
  }

  // This will be executed when the document unloads...
  unmount() {

  }
}