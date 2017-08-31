// web/static/js/views/loader.js

import MainView    from './main';
import AdminIndexView from './admin/index';
import TopicShowView from './topic/show';

// Collection of specific view modules
const views = {
  AdminIndexView,
  TopicShowView,
};

export default function loadView(viewName) {
  return views[viewName] || MainView;
}