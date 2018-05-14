/* global $ */
import { Socket } from 'phoenix';

// connect socket
const socket = new Socket('/socket', {
  params: {
    token: $('meta[name="token"]').attr('content')
  }
});
socket.connect();

const publicChannel = socket.channel('public', {});

// join public channel and listen for public events
export function configPublicChannel() {
  publicChannel.join();
  publicChannel.on('new:idea', ({ id, open }) => {
    // update badge in navbar
    if (window.topic_id != id && (window.admin || open)) {
      const elm = $(`.badge[data-topic-id=${id}]`);
      elm.text(parseInt(elm.html(), 10) + 1).removeClass('d-none');
    }
  });
}

export default socket;
