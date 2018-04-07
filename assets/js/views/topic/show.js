// web/static/js/views/topic/show.js
/* global $ */
import MainView from '../main';

export default class View extends MainView {
  mount() {
    super.mount();
    const show = $('#submitIdeaModal').data('show') ? 'show' : 'hide'
    $('#submitIdeaModal').modal(show)
  }

  unmount() {
    super.unmount();
  }
}