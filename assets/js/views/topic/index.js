// web/static/js/views/user/index.js
/* global $ */
import Turbolinks from "turbolinks"
import MainView from '../main'

require( 'datatables.net-bs4' )();

const renderDetails = function (row) {
  const short_desc = $(this.node()).data('short-desc')
  this.child(short_desc).show();
}

export default class View extends MainView {
  mount() {
    super.mount();

    $('#topics').DataTable({
      info: false,
      paging: false,
      searching: false,
      stateSave: true
    })
    .rows().every(renderDetails)

    $('#topics').on('click', 'tbody tr.pointer', e =>
      Turbolinks.visit($(e.currentTarget).data('path')))

    $('#topics').on('click', 'a', e => { e.stopImmediatePropagation() })
  }

  unmount() {
    super.unmount();
    $('#topics').DataTable().destroy()
  }
}