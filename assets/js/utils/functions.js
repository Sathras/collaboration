import $ from 'jquery'

export function configTimeago() {
  $.timeago.settings.allowFuture = true;
  $.timeago.settings.strings = {
    prefixAgo: null,
    prefixFromNow: null,
    suffixAgo: 'ago',
    suffixFromNow: 'remaining',
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
