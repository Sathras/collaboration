// Brunch automatically concatenates all files in your
// watched paths. Those paths can be configured at
// config.paths.watched in "brunch-config.js".
//
// However, those files will only be executed if
// explicitly imported. The only exception are files
// in vendor, which are never wrapped in imports and
// therefore are always executed.

// Import dependencies
//
// If you no longer want to use a dependency, remember
// to also remove its path from "config.paths.watched".
import "phoenix_html"

// Import local files
//
// Local files can be imported directly using relative
// paths "./socket" or full ones "web/static/js/socket".

import topicChannel from "./channel_topic"

import $ from 'jquery'

// enable TimeAgos
import timeago from 'timeago'
$("time.timeago").timeago();


import "./datatable"



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
});