// web/static/js/views/admin/users.js

import $ from 'jquery'
let dt = require( 'datatables.net-bs4' )( $ );
import MainView from '../main'

export default class View extends MainView {
  mount() {
    super.mount();

    $('#users-table').DataTable()
  }

  unmount() {
    super.unmount();

  }
}
