# Changelog
If versions are ommited from the changelog they only contain deployment updates

## TODO
This is a list of open issues.
  *  Redirect non-admin users automatically if currently visited topic gets closed
  *  Update Instructions for all users upon change
  *  Update Topiclist in /topics automatically upon change
  *  Update Topic Description automatically upon change
  *  When editing idea, allow to change user as well or remove field
  *  Allow normal users to edit their own ideas
  *  Add fake likes
  *  add rating mechanism for ideas

### 0.3.2 - 09/07/2017
  *  Fixed: When not logged in comments and likes are still shown
  *  Added: users can now sort idea list by date, rating and comments
  *  Added: Fake Ratings (placeholder)

### 0.3.1 - 09/06/2017
  *  Added: Deployment Script that allows to make the first user a admin

### 0.3.0 - 09/05/2017
  *  Added: Admin Channel & Admin Interface now utilizes sockets
  *  Added: Option to toggle topic hidden and visible directly from admin area
  *  Added: Admin Instructions Intelligent Save Button that enables and disables on changes and save
  *  Removed: Datatables dependency (now using list.js)
  *  Added: Making topics visible in admin now hides/shows them for all users in menu
  *  Added: Current Topic / Home is highlighted in the menubar
  *  Fixed: Increased Size of Input submit form
  *  Fixed: Made Navbar stick to the top (permanently visible)
  *  Moved: submit idea button is now in navbar on the top
  *  Added: Icons on several buttons
  *  Added: Idea Description now uses a nice editor for basic styling
  *  Added: Submitted Ideas now show up directly on screen (no page reload required)
  *  Added: Validation for submitted ideas
  *  Added: Canceling an idea submission now empties the form and resets validation states
  *  Added: Admins can now edit any idea
  *  Fixed: Normal users can now post ideas too, if the topic is open
  *  Fixed: Instructions Button and Popup is now only visible when the user is logged in and the topic is open
  *  Added: Admins can now delete ideas (a warning is displayed beforehand)
  *  Added: Users can now leave comments
  *  Added: Upon successful comment, comment field is now emptied
  *  Added: Upon unsuccessful comment, comment field is now highlighted in red (error)
  *  Added: Admins can now delete comments (no confirmation needed)
  *  Added: The time since ideas / comments have been posted is now displayed and updated automatically
  *  Fixed: Dates now account for correct timezone
  *  Added: Users can now like and unlike comments
  *  Fixed: Deleting comments now deletes all reactions to it
  *  Fixed: Deleting ideas now deletes all comments and reactions to it
  *  Fixed: Deleting topics now deletes all ideas, comments, and reactions to it
  *  Added: Sort/Filter/Search Bar for ideas that sticks to the top when scrolling down
  *  Added: Searching Ideas is now possible (applies a filter)

### 0.2.26 - 08/25/2017
  *  Fixed: Internal Port/Network Issues

### 0.2.20 - 08/24/2017
  *  Improved: Much more pleasing Topic/Idea/Comment List

### 0.2.12 - 08/23/2017
  *  Fixed: Several Minor Bugs
  *  Fixed: Topics now only shows associated ideas (admin)
  *  Fixed: Topics now only shows associated ideas that have been submitted by faux users or user himself (normal)
  *  Added: Validation for Idea input
  *  Changed: Comments now only include the firstname of the user instead of first and last
  *  Changed: Ideas now load via socket
  *  Added: Client-Side dynamic Javascript Asset Management

### 0.2.5 - 08/22/2017
  *  Added: Normal Users can now only submit ideas to open topics
  *  Fixed: Bug in Admin view that would display multiple tabs at once
  *  Added: Comments
  *  Added: Normal users can't comment on closed topics

### 0.2.4 - 08/21/2017
  *  Added: Datatables
  *  Added: In admin view you can now sort and search tables

### 0.2.0 - 08/20/2017
  *  Added: Topic Management in Admin Area
  *  Added: Topics in Menubar for easy access
  *  Added: Topics order based on order number
  *  Added: MCE editor for beaufiful description editing
  *  Added: Option to Hide / Show Topic
  *  Added: Hidden Topics appear gray in the Admin Management List
  *  Added: Admin Management - Instructions
  *  Added: Authentificated Users now have a button with instructions in menu
  *  Added: admin option to open/close topics
  *  Added: Users can now set to Faux Users
  *  Added: Ideas
  *  Added: Admins can post as Faux Users

### 0.1.0 - 08/18/2017
  *  Added: Admin User Level implemented
  *  Added: Restricted Admin area to admins
  *  Status: Marks the completion of the Initial User Management

#### 0.0.3 - 08/18/2017
  *  Status: Finished Login and Registration
  *  Added: Admin Interface
  *  Added: Settings (for change password is required)
  *  Added: In Admin Interface you can now change users data (no password required)

#### 0.0.2 - 08/16/2017
  *  Added: Integrated Bootstrap v4, JQUERY and SASS (and Popper dependency)
  *  Added: fixed flash message system
  *  Added: finished register form including server-side validation

#### 0.0.1 - 08/16/2017
  *  Added: Initial Release
  *  Added: Installed Phoenix Framework, Postgres 9.6 and set up dev environment


