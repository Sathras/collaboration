// web/static/js/views/admin/topics.js

import $ from 'jquery'
let dt = require( 'datatables.net-bs4' )( $ );
import MainView from '../main'

export default class View extends MainView {
  mount() {
    super.mount();

    $('#topics-table').DataTable()
  }

  unmount() {
    super.unmount();

  }
}
