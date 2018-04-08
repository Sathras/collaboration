// web/static/js/views/loader.js
import MainView    from './main';
import IdeaIndexView from './idea/index';
import TopicEditView from './topic/edit';
import TopicIndexView from './topic/index';
import TopicNewView from './topic/new';
import UserIndexView from './user/index';

// Collection of specific view modules
const views = {
  IdeaIndexView,
  TopicEditView,
  TopicIndexView,
  TopicNewView,
  UserIndexView
};

export default function loadView(viewName) {
  return views[viewName] || MainView;
}