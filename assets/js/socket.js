/* global $ */
import { Socket } from 'phoenix';

// connect socket
const socket = new Socket('/socket', {
  params: {
    token: $('meta[name="token"]').attr('content')
  }
});
socket.connect();

// join public channel and listen for public events
export function configPublicChannel() {
  const publicChannel = socket.channel('public', {});
  publicChannel.join();

  publicChannel.on('new:idea', ({ id }) => {
    // update badge in navbar
    if(window.topic_id != id){
      const elm = $(`.badge[data-topic-id=${id}]`)
      elm.text(parseInt(elm.html(), 10) + 1).removeClass('d-none')
    }
  });
}

export default socket;
