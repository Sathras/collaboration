// web/static/js/views/user/index.js
/* global $ */
import MainView from '../main';

export default class View extends MainView {
  mount() {
    super.mount();
    $('#users').DataTable({stateSave: true});
  }

  unmount() {
    super.unmount();
    $('#users').DataTable().destroy()
  }
}