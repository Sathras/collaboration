// web/static/js/views/loader.js
import MainView    from './main';
import TopicEditView from './topic/edit';
import TopicIndexView from './topic/index';
import TopicNewView from './topic/new';
import TopicShowView from './topic/show';
import UserIndexView from './user/index';

// Collection of specific view modules
const views = {
  TopicEditView,
  TopicIndexView,
  TopicNewView,
  TopicShowView,
  UserIndexView
};

export default function loadView(viewName) {
  return views[viewName] || MainView;
}