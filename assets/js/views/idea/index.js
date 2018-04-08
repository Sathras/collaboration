// web/static/js/views/idea/index.js
/* global $, Turbolinks */
import MainView from '../main';

export default class View extends MainView {
  mount() {
    super.mount();

    $('#ideas').DataTable({
      "order": [[ 1, 'desc' ]]
    });
    $('#ideas').on('click', 'tbody tr', e =>
      Turbolinks.visit($(e.currentTarget).data('path')))

    // show a specific modal if invalid formdata was submitted
    let show = $('#submitIdeaModal').data('show') ? 'show' : 'hide'
    $('#submitIdeaModal').modal(show)
    show = $('#editIdeaModal').data('show') ? 'show' : 'hide'
    $('#editIdeaModal').modal(show)

  }

  unmount() {
    super.unmount();
    $('#ideas').DataTable().destroy()
  }
}