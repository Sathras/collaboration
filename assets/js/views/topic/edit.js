import { toggleMCE } from '../../utils/functions';
import MainView from '../main';

export default class View extends MainView {
  mount() {
    super.mount();
    toggleMCE('topic_short_desc');
    toggleMCE('topic_desc');
  }

  unmount() {
    super.unmount();
    toggleMCE('topic_short_desc');
    toggleMCE('topic_desc');
  }
}
