/* global $ */
import socket from '../../socket';
import MainView from '../main';

class View extends MainView {
  mount() {
    super.mount();

    // reset badge in navbar
    $(`.badge[data-topic-id=${window.topic_id}]`).text(0).addClass('d-none')

    this.comments = $('#comments');
    this.feedback = $('#feedback');

    this.idea = null;
    this.editable = this.admin || (this.user && window.topic_open);

    // join topic channels
    this.config_topic_channel(window.topic_id);
  }

  config_topic_channel(id) {
    this.topicChannel = socket.channel(`topic:${id}`, {});
    this.topicChannel.join().receive('ok', resp => {
      let ids = resp.ideas.map(i => i.id);
      if (ids.length > 0)
        this.topicChannel.params.last_seen_id = Math.max(...ids);

      if (!this.ideasTable) {
        this.ideasTable = $('#ideas').DataTable({
          data: resp.ideas,
          columns: [
            { data: 'title', title: 'Title' },
            { data: 'rating', title: "<i class='fas fa-star'></i>" },
            { data: 'comment_count', title: "<i class='far fa-comments'></i>" },
            {
              data: 'created',
              title: "<i class='far fa-clock mr-2'></i>",
              render: data => `<small><time datetime='${data}'></time></small>`,
              width: 60
            }
          ],
          order: [[3, 'desc']],
          rowId: 'js_id',
          safeState: true,
          select: { style: 'single', className: 'table-primary' }
        });
        $('#ideas time').timeago();
      }

      // loading/unloading idea when selecting/deselecting rows in idea table
      this.ideasTable.on('select', (e, dt, type, indexes) =>
        this.load_idea(indexes)
      );
      this.ideasTable.on('deselect', () => this.unload_idea());
    });

    // differentiate add / edit idea modal
    $('#ideaModal').on('show.bs.modal', event => {
      const edit = $(event.relatedTarget).data('action') === 'update:idea';
      const data = edit
        ? this.idea
        : { title: '', desc: '', fake_rating: '', fake_raters: 0 };

      // update modal with new data
      $(this)
        .find('.modal-title')
        .text(edit ? 'Edit Idea' : 'Add Idea');
      $('#idea_title').val(data.title);
      $('#idea_desc').val(data.desc);
      $('#idea_fake_rating').val(data.fake_rating);
      $('#idea_fake_raters').val(data.fake_raters);
      $('#idea-form').data('action', $(event.relatedTarget).data('action'));

      // remove all errors
      $('#ideaModal input, #ideaModal textarea').removeClass(
        'is-valid is-invalid'
      );
    });

    // Submit Add/Edit Idea Form
    $('#idea-form').on('submit', e => {
      e.preventDefault();
      const action = $('#idea-form').data('action');
      const data = {
        id: this.idea ? this.idea.id : null,
        title: $('#idea_title').val(),
        desc: $('#idea_desc').val(),
        fake_rating: $('#idea_fake_rating').val(),
        fake_raters: $('#idea_fake_raters').val()
      };
      this.topicChannel
        .push(action, data)
        .receive('ok', () => {
          $('#ideaModal').modal('hide');
        })
        .receive('error', res => {
          if (res.errors) {
            $('#ideaModal input, #ideaModal textarea').addClass('is-valid');
            $('#ideaModal .invalid-feedback').text('');
            $.each(res.errors, (field, error) => {
              $('#idea_' + field)
                .removeClass('is-valid')
                .addClass('is-invalid')
                .siblings('.invalid-feedback')
                .text(error);
            });
          }
        });
    });

    // Delete Idea
    $('#deleteIdea').on('click', e => {
      var confirmed = confirm(
        'Are you sure? This will delete all associated ratings, comments and likes!'
      );
      if (confirmed)
        this.topicChannel.push('delete:idea', { id: this.idea.id });
    });

    // TOPIC CHANNEL EVENTS

    // Response to broadcast event "new:idea"
    this.topicChannel.on('new:idea', idea => {
      this.topicChannel.params.last_seen_id = idea.id;
      this.ideasTable.row
        .add(idea)
        .draw()
        .node();
      $('#ideas time').timeago();
    });

    // Response to broadcast event "update:idea"
    this.topicChannel.on('update:idea', idea => {
      this.ideasTable
        .row(`#idea_${idea.id}`)
        .data(idea)
        .draw();
      $('#ideas time').timeago();
      // if currently selected idea matches updated idea, update idea panel
      if (this.idea && this.idea.id === idea.id) this.update_idea_panel(idea);
    });

    // Response to broadcast event "delete:idea"
    this.topicChannel.on('delete:idea', idea => {
      this.ideasTable
        .row(`#idea_${idea.id}`)
        .remove()
        .draw();
      // if currently selected idea matches deleted idea, close idea panel
      if (this.idea && this.idea.id === idea.id) this.unload_idea(idea);
    });
  }

  load_idea(indexes) {
    this.idea = this.ideasTable
      .rows(indexes)
      .data()
      .toArray()[0];

    // update idea panel with new idea information
    this.update_idea_panel(this.idea);
    $('#no-idea').addClass('d-none');
    $('#idea').removeClass('d-none');

    this.ideaChannel = socket.channel(`idea:${this.idea.id}`, {});
    this.ideaChannel.join().receive('ok', resp => {
      let ids = resp.comments.map(c => c.id);
      if (ids.length > 0)
        this.ideaChannel.params.last_seen_id = Math.max(...ids);

      if (resp.comments.length > 0) $('#no_feedback').remove();
      resp.comments.forEach(c => this.comments.append(this.messageTemplate(c)));
      $('#comments time').timeago();
    });

    this.feedback.off('keypress').on('keypress', e => {
      if (e.keyCode == 13) {
        this.ideaChannel
          .push('new:feedback', { text: this.feedback.val() })
          .receive('ok', () => {
            this.feedback.val('').removeClass('is-invalid');
          })
          .receive('error', res => {
            this.feedback.addClass('is-invalid');
          });
      }
    });

    this.ideaChannel.on('new:feedback', feedback => {
      this.ideaChannel.params.last_seen_id = feedback.id;
      this.comments.append(this.messageTemplate(feedback));
      $('#no_feedback').hide();
      $('#comments time').timeago();
      scrollTo(0, document.body.scrollHeight);
    });

    this.ideaChannel.on('update:feedback', feedback => {
      // currently: just update likes and fake likes
      $(`#comments li[data-id=${feedback.id}] input`).val(feedback.fake_likes);
      const likes = $(`#comments li[data-id=${feedback.id}] .likes`);
      likes.text(feedback.likes);
      feedback.likes > 0
        ? likes.removeClass('d-none')
        : likes.addClass('d-none');
    });

    this.ideaChannel.on('delete:feedback', ({ id }) => {
      $(`#comments li[data-id=${id}]`).remove();
    });

    if (window.admin) {
      // Delete Feedback
      $('#comments').on('click', 'a.delete', e => {
        this.ideaChannel.push('delete:feedback', {
          id: $(e.currentTarget)
            .closest('li')
            .data('id')
        });
      });
    }

    $('#comments').on('click', 'a.like', e => {
      const elm = $(e.target);
      const comment = elm.closest('li').data('id');
      if (elm.html().trim() === 'Like')
        this.ideaChannel
          .push('like:feedback', { comment })
          .receive('ok', () => {
            elm.html('Unlike');
          });
      else
        this.ideaChannel
          .push('unlike:feedback', { comment })
          .receive('ok', () => {
            elm.html('Like');
          });
    });

    $('#comments').on('focus', 'input.fake-ratings', e => {
      e.target.select();
    });
    $('#comments').on('change', 'input.fake-ratings', e => {
      const comment = $(e.target)
        .closest('li')
        .data('id');
      const fake_likes = $(e.target).val();
      this.ideaChannel.push('update:fake_likes', { comment, fake_likes });
    });

    // clicking on rating icon should trigger rating
    $('#rate').on('change', 'input', e => {
      this.ideaChannel.push('rate', { rating: e.target.value });
    });
  }

  update_idea_panel(idea) {
    $('#idea h4').text(idea.title); // update heading
    idea.desc // update description
      ? $('#idea-desc')
          .removeClass('d-none')
          .html(idea.desc)
      : $('#idea-desc').addClass('d-none');
    if (idea.rating) {
      // toggle rating
      $('#rating').removeClass('d-none');
      $('#rating strong').html(idea.rating);
      $('#rating small span').text(idea.raters);
    } else $('#rating').addClass('d-none');
    idea.user_rating // update user rating
      ? $('#star' + idea.user_rating).attr('checked', true)
      : $('#rate input').removeAttr('checked');
  }

  unload_idea() {
    // leave idea channel, empty feedbacks and hide idea panel
    this.idea = null;
    this.ideaChannel.leave();
    $('#no-idea').removeClass('d-none');
    $('#idea').addClass('d-none');
    this.comments.html(this.no_feedback_template());
  }

  sanitize(html) {
    return $('<div/>')
      .text(html)
      .html();
  }

  messageTemplate(comment) {
    const thumbsup =
      window.admin || (window.user && window.topic_open)
        ? `<i class="far fa-thumbs-up text-primary"></i>`
        : ``;

    const like_btn =
      window.admin || (window.user && window.topic_open)
        ? `<a class="like text-primary pointer">Like</a>`
        : ``;

    const hidden = comment.likes === 0 ? `d-none` : ``;

    const administrate = window.admin
      ? `<span class="float-right">
          <small class="text-muted font-italic">
            Fake Likes:
            <input type="number" class="fake-ratings text-primary" value="${
              comment.fake_likes
            }" />
            <a class="delete pointer">
              <i class="text-danger fas fa-trash-alt"></i>
            </a>
          </small>
        </span>`
      : ``;

    return `
      <li class="list-group-item px-2 py-1" data-id="${comment.id}">
        <small class="ml-1 float-right font-italic text-muted">
          <time datetime="${comment.created}"></time>
        </small>
        <strong>${comment.author}</strong><br>
        ${this.sanitize(comment.text)}<br>
        <span>
          ${thumbsup}
          <div class="likes badge badge-primary ${hidden}">${comment.likes ||
      ''}</div>
          ${like_btn}
          ${administrate}
        </span>
      </li>
    `;
  }

  no_feedback_template() {
    return `
      <li id="no_feedback" class="list-group-item px-2 py-1 font-italic text-center">
        no feedback yet...
      </li>
    `;
  }

  unmount() {
    super.unmount();
    this.ideasTable.destroy();
    this.ideasTable = null;
    this.topicChannel.leave();
    if (this.ideaChannel) this.ideaChannel.leave();
  }
}

export default View;
