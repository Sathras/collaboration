# Changelog

## 2.0.0
Complete Remade of the Application. Working Features:
 * Registration / Authentication with password reset, email confirmation and change account functionality
 * Topic Management
   * Topics can be open/closed. Normal users can not submit ideas, ratings or likes in closed topics.
   * Topics can be featured. Featured topics appear in the navigation bar directly as a link.
   * Topics can be published/unpublished. Unpublished topics are not visible by anonymous or normal users. Published but unfeatured topics still appear in the topic overview list (default homepage).
   * Topics have a short description, that is visible in the topic overview and on mouseover in the navigation bar
   * Topics have a long description, that is visible when a topic is opened
   * topics have a short title (menu) and a title (overview, topic pages)
   * Topic in Overview can be sorted and filtered in a smart table. Admins see more details. Clicking on a row opens the topic
 * Ideas Management (topic page)
   * Ideas can be added/edited in open, published topics (admins can always post ideas)
   * When adding/editing an idea Admins can additionally set a fake rating and a fake user count. The real rating and real user count for ratings are aggregated.
   * The page is split in two halfs:
     * Idealist (left side)
     * On the left side a smart table showing a list of all ideas and avg. rating, # comments and when it was published. default sorted by date desc. Clicking on an idea opens the feedback panel on the right side.
   * Feedback Panel (right side)
   * a list of feedbacks/comments sorted by date.
   * Authenticated users (if topic is open) and admins can post feedback. Besides the feedback text, the name of the user and time is posted.
   * In open topics or if admin, users may like feedback (or remove their likes). this dynamically increases the like counter without need to reload the page. Also comments are added/removed dynamically.
   * Admins have the option to delete comments and set a fake like counter that gets added to the real like counter.
 * User Management (Admins only)
   * Currently, users can be toggled to admins.
   * Users can be added/ Removed from Feedback condition. By default new users are randomly in Feedback condition.
 * Convenience features such as automatic update of times (e.g. 3 minutes ago switches to 4 minutes ago after a minute).
 * For many actions updates in the database are directly broadcasted to connected clients, causing their user interfaces to update (like in a chat). More functionality will be extended to this behavior.
 * Usage of turbolinks that prevents full page reloads when links are followed and instead only replace the body through an ajax request resulting in much website faster performance. In general, I went wild with a lot of things I have learned in the last months. :)