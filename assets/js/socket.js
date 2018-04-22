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
  publicChannel.join().receive('ok', ({ topics }) => {
    // add topics to navigation bar
    $.each(topics, (i, t) => {
      $('#nav-topics').append(`
        <a class="nav-link" href="/topics/${t.id}" data-content="${
        t.short_desc
      }">
          ${t.short_title}<span class="badge badge-pill badge-light ml-1 d-none"
          data-topic-id="${t.id}">0</span>
        </a>
      `);
    });
  });

  publicChannel.on('new:idea', ({ id }) => {
    // update badge in navbar
    if (window.topic_id != id) {
      const elm = $(`.badge[data-topic-id=${id}]`);
      elm.text(parseInt(elm.html(), 10) + 1).removeClass('d-none');
    }
  });
}

export default socket;
