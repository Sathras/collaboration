// web/static/js/views/user/index.js
/* global $ */
import MainView from '../main';
require( 'datatables.net-bs4' )();


function renderDetails (row) {
  console.log(row)
  return row
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
    .rows().every(function () {
      var tr = $(this.node());
      this.child(renderDetails(tr.data('short-desc'))).show();
      tr.addClass('shown');
    })
  }

  unmount() {
    super.unmount();
  }
}