import MainView from './main';
import AdminUsersView from './admin/users';
import TopicEditView from './topic/edit';
import TopicIndexView from './topic/index';
import TopicNewView from './topic/new';
import TopicShowView from './topic/show';

// Collection of specific view modules
const views = {
  AdminUsersView,
  TopicShowView,
  TopicEditView,
  TopicIndexView,
  TopicNewView
};

export default function loadView(viewName) {
  return views[viewName] || MainView;
}
