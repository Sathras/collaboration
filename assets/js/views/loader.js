import MainView from './main';
import TopicEditView from './topic/edit';
import TopicNewView from './topic/new';

// Collection of specific view modules
const views = {
  TopicEditView,
  TopicNewView
};

export default function loadView(viewName) {
  return views[viewName] || MainView;
}
