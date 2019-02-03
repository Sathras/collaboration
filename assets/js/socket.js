import $ from 'jquery'
import { Socket } from 'phoenix'

// get user variables from tags
// const user_id = $('meta[name=user_id]').attr('content');
const user_token = $('meta[name=user_token]').attr('content');

// connect socket
const params = user_token ? { user_token } : {};
const socket = new Socket('/socket', { params });
socket.connect();

// if (user_id) {
//   const userChannel = socket.channel(`user:${user_id}`, {});

//   // define events
//   userChannel.on('new_feedback', ({ idea_id, comment }) => {
//     $(`#idea${idea_id} .comments`).append(comment);
//     $(`#idea${idea_id} .comments li:last-child time`).timeago();
//     Drab.enable_drab_on(`#idea${idea_id} .comments li:last-child`);
//   });

//   // join user channel
//   userChannel.join();
// }

export default params;
