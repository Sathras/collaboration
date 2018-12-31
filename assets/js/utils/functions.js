import $ from 'jquery'

export function configTimeago() {
  $.timeago.settings.strings = {
    prefixAgo: null,
    prefixFromNow: null,
    suffixAgo: 'ago',
    suffixFromNow: 'from now',
    seconds: 'less than a minute',
    minute: 'a minute',
    minutes: '%d minutes',
    hour: 'an hour',
    hours: '%d hours',
    day: 'a day',
    days: '%d days',
    month: 'a month',
    months: '%d months',
    year: 'a year',
    years: '%d years',
    wordSeparator: ' ',
    numbers: []
  };
}

export function toggleMCE(editorId) {
  if (tinymce.get(editorId)) {
    tinymce.EditorManager.execCommand('mceFocus', false, editorId);
    tinymce.EditorManager.execCommand('mceRemoveEditor', true, editorId);
  } else {
    tinymce.EditorManager.execCommand('mceAddEditor', false, editorId);
  }
}

// EXPOSE GLOBAL FUNCTIONS

// autogrow text input when editing ideas or comments
window.auto_grow = element => {
  element.style.height = '30px';
  element.style.height = element.scrollHeight + 'px';
};
