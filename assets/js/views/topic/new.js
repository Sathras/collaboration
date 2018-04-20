/* global $ */
import { string_to_slug, toggleMCE } from '../../utils/functions';
import MainView from '../main';

export default class View extends MainView {
  mount() {
    super.mount();

    toggleMCE('topic_short_desc');
    toggleMCE('topic_desc');

    $('#topic_short_title').change(e => {
      const slug = string_to_slug(e.target.value);
      $('#topic_slug').val(slug);
      $('#slug').html(slug);
    });
  }

  unmount() {
    super.unmount();
    toggleMCE('topic_short_desc');
    toggleMCE('topic_desc');
  }
}
