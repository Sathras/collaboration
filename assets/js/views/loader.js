// web/static/js/views/loader.js
import MainView    from './main';
import TopicNewView from './topic/new';
import TopicEditView from './topic/edit';
import TopicIndexView from './topic/index';
import UserIndexView from './user/index';

// Collection of specific view modules
const views = {
  TopicIndexView,
  TopicNewView,
  TopicEditView,
  UserIndexView
};

export default function loadView(viewName) {
  return views[viewName] || MainView;
}