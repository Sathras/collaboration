import MainView from './main';
import TopicEditView from './topic/edit';
import TopicIndexView from './topic/index';
import TopicNewView from './topic/new';
import TopicShowView from './topic/show';

// Collection of specific view modules
const views = {
  TopicShowView,
  TopicEditView,
  TopicIndexView,
  TopicNewView
};

export default function loadView(viewName) {
  return views[viewName] || MainView;
}
