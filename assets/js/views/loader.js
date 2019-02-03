import MainView from './main'
import TopicEditView from './topic/edit'
import TopicNewView from './topic/new'
import TopicShowView from './topic/show'

// Collection of specific view modules
const views = {
  TopicEditView,
  TopicNewView,
  TopicShowView
};

export default function loadView(viewName) {
  return views[viewName] || MainView;
}
