import $ from 'jquery'
import MainView from '../main'

export default class View extends MainView {
  mount() {
    super.mount();

    // toggles star rating for submitting a user rating
    $("body").on('click', '.user-rating', (e) => {
      $(e.currentTarget).siblings().toggle()
    });
  }

  unmount() {
    super.unmount();
  }
}
