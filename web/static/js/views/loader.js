// web/static/js/views/loader.js

import MainView    from './main';
import AdminTopicsView from './admin/topics';
import AdminUsersView from './admin/users';
import TopicShowView from './topic/show';

// Collection of specific view modules
const views = {
  AdminTopicsView,
  AdminUsersView,
  TopicShowView,
};

export default function loadView(viewName) {
  return views[viewName] || MainView;
}