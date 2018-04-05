// web/static/js/views/loader.js
import MainView    from './main';
import UserIndexView from './user/index';

// Collection of specific view modules
const views = {
  UserIndexView,
};

export default function loadView(viewName) {
  return views[viewName] || MainView;
}