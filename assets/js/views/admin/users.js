/* global $ */
import socket from '../../socket';
import C from '../../utils/constants';
import MainView from '../main';

export default class View extends MainView {
  mount() {
    super.mount();
    this.config_userChannel();
  }

  unmount() {
    super.unmount();
    this.userTable.destroy();
    this.userTable = null;
    this.userChannel.leave();
  }

  config_userChannel() {
    const channel = socket.channel(`admin:users`, {});
    channel.join().receive('ok', ({ users }) => {
      if (users.length > 0) channel.params.last = users.slice(-1)[0].created;

      this.userTable = $('#users').DataTable({
        ...C.DATATABLE_BASE_CONFIG,
        data: users,
        columns: [
          { data: 'name', title: 'Name', responsivePriority: 1 },
          { data: 'email', title: 'Email', responsivePriority: 3 },
          {
            data: 'admin',
            title: '<i class="fas fa-user"></i>',
            render: admin =>
              admin
                ? `<i data-toggle='admin' class="pointer fas fa-user-plus text-primary"></i>`
                : `<i data-toggle='admin' class="pointer fas fa-user"></i>`,
            width: 20,
            responsivePriority: 2
          },
          {
            data: 'feedback',
            title: '<i class="fas fa-comment"></i>',
            render: feedback =>
              feedback
                ? `<i data-toggle='feedback' class="pointer fas fa-comment"></i>`
                : `<i data-toggle='feedback' class="pointer fas fa-comment-slash text-muted"></i>`,
            width: 20,
            responsivePriority: 2
          }
        ]
      });

      $('#users_filter input').addClass('form-control form-control-sm')
    });

    // USER CHANNEL EVENTS

    // Response to broadcast event "new:user"
    channel.on('new:user', user => {
      channel.params.last = user.created;
      this.userTable.row
        .add(user)
        .draw()
        .node();
    });

    // Response to broadcast event "update:user"
    channel.on('update:user', user => {
      this.userTable
        .row(`#user_${user.id}`)
        .data(user)
        .draw();
    });

    // Response to broadcast event "delete:user"
    channel.on('delete:user', user => {
      this.userTable
        .row(`#user_${user.id}`)
        .remove()
        .draw();
    });

    // TOGGLE EVENTS

    // toggle various user flags
    $('#users').on('click', '[data-toggle]', e => {
      const user = this.userTable.row($(e.target).closest('tr')).data().id;
      const field = $(e.target).data('toggle');
      channel.push('toggle', { user, field });
    });

    this.userChannel = channel;
  }
}
