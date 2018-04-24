# Changelog

## 2.0.5
 * Topic Desc, Shortdesc, Idea Desc and Comment Text can now be indefiniately long (bug that prevented e.g. changing topics and adding images)
 * When editing topics you can now make use of 2 styling options "Image Left" and "Image Right" which automatically floats the image in the text

## 2.0.4
 * Admin Users Table is now fully responsive with sticky header and removed pagination
 * Ideas Table now fully responsive with sticky header and removed pagination
 * Cleaned up Ideas Panel Header

## 2.0.3
 * Fixed several bugs
 * automatic feedback now only visible to the user who posted the idea

## 2.0.2
 * On idea submission, server will automatically post a response comment from a random feedback user (after 30 seconds) that can only be seen by the posting user
 * Improved Admin Users page
 * Added a few test users with feedback condition
 * ideas are now always sorted with newest one first descending

## 2.0.1
 * Added automated Prettier Codestyle for JS and CSS
 * If new ideas are posted in a topic that is not the currently active topic, a badge appears that indicates the number of new ideas in that topic. resets when topic is opened.
 * My-Rating is now preserved in view when navigating through ideas / on page load.

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