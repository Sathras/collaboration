// web/static/js/views/topic/edit.js
/* global $ */
import { string_to_slug } from '../../utils/functions'
import MainView from '../main';

export default class View extends MainView {
  mount() {
    super.mount();
    $('#topic_short_title').change(e => {
      const slug = string_to_slug(e.target.value)
      $('#topic_slug').val(slug)
      $('#slug').html(slug)
    })
  }

  unmount() {
    super.unmount();

  }
}