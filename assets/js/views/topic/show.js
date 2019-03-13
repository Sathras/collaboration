import $ from 'jquery'
import MainView from '../main'

import socket from '../../utils/socket'

export default class View extends MainView {

  comment(id, cid, author, text, delay){

    var date = new Date()
    date = new Date(date.getTime() + delay * 1000 )
    date = date.toISOString()
    const comment = `<li id="comment${cid}" class="list-group-item pb-1 pt-2 comment" data-liked="false" data-likes="0" data-remaining="0">
    <p class="mb-0 text-justify">
      <small><strong class="mr-1">${author}</strong>${text}</small>
    </p>
    <p class=" mb-1">
      <small>
        <i class="text-primary far fa-thumbs-up"></i>
        <span class="likes badge badge-pill badge-primary mr-1 d-none">0</span>
        <small class="text-primary" drab-click="like(${cid})" drab="click:like(${cid})">Like</small>
        <time class="font-italic float-right" datetime="${date}"></time>
      </small>
    </p>
  </li>`;

    switch($(`#idea${id} .comment`).length){
      case 0:
      case 1:
        $(`#idea${id} .comments`).append(comment).find('time').timeago()
        break;
      default:
        let done = false
        $(`#idea${id} .comment`).each(function(){
          if(done) return false;
          if($(this).find('time').attr('datetime') > date ){
            $(this).before(comment).find('time').timeago()
            done = true
          }
        });
    }
    // window.user.comments.push(cid);
  }

  like(comment_id){
    const comment = $(`#comment${comment_id}`)
    const likes = comment.data('likes')
    comment
      .data('likes', likes + 1)
      .find('.likes').text(likes + 1).removeClass('d-none')
  }

  rate(idea_id, newRating){
    const ratingElm = $(`#idea${idea_id} .rating strong`)
    const ratersElm = $(`#idea${idea_id} .raters strong`)
    const uRatingElm = $(`#idea${idea_id} .user-rating strong`)
    const rating = parseFloat(ratingElm.text()) || 0
    const raters = parseInt(ratersElm.text())
    const uRating = parseInt(uRatingElm.text())

    let finalRating = uRating
      ? (newRating + uRating + rating * raters) / (raters + 1)
      : (newRating + rating * raters) / (raters + 1)
    finalRating = Math.round(finalRating * 10) / 10

    ratingElm.text(finalRating)
    ratersElm.text(raters +1)
  }

  schedule_idea(i){
    if(i[1]) setTimeout(() =>
      { $(`#ideas`).append(i[0]).find('time').first().timeago() }, 1000 * i[1])
    else $(`#ideas`).append(i[0]).find('time').first().timeago()
  }

  schedule_comment(c){
    if(c[2]) setTimeout(() => {
      $(`#idea${c[0]} .comments`).append(c[1]).find('time').last().timeago()
    }, 1000 * c[2])
    else $(`#idea${c[0]} .comments`).append(c[1]).find('time').last().timeago()
  }

  schedule_like(like){
    setTimeout(this.like(like[0]), 1000 * like[1])
  }

  schedule_rating(rating){
    setTimeout(this.rate(rating[0], rating[2]), 1000 * rating[1])
  }

  checkReload() {
    // reloads page every 30 seconds unless currently focusing on an input
    if(!this.writeFocus) location.reload(true);
  }

  joinChannel(){
    socket.connect()
    const channel = socket.channel("topic")

    // enable posting of ideas
    $('#idea-form').on('submit', (e) => {
      e.preventDefault()
      e.stopPropagation()
      if ($('#idea-form')[0].checkValidity() === false)
        $('#idea-form').addClass('was-validated')
      else {
        channel.push('create_idea', { text: $(e.target).find('textarea').val()})
        .receive("ok", ({ idea, feedback }) => {

          // schedule idea and feedback if required
          this.schedule_idea([idea])
          if(feedback) this.schedule_comment(feedback)

          // append idea
          $('#ideas').prepend(idea).find('time').first().timeago()

          // reset submit idea form
          $(e.target).find('textarea').val('')
          $(e.target).removeClass('was-validated')
        })
      }
    });

    // enable posting of comments
    $('#ideas').on('keypress', '.idea textarea', (e) => {

      // enables to submit feedback with Enter, but not shift enter (new line)
      if(e.which == 13 && !e.shiftKey) {

        const elm = $(e.target)

        if(elm.val().length < 10 || elm.val().length > 500){
          elm.addClass('is-invalid')
          elm.siblings('.invalid-feedback')
            .text('Comment need to have between 10 and 200 characters.')
          return false;
        }

        channel.push('create_comment', {
          idea_id: elm.data('idea_id'),
          text: elm.val()
        })
        .receive("ok", ({ comment, feedback }) => {
          // schedule comment and feedback if required
          this.schedule_comment(comment)
          if(feedback) this.schedule_comment(feedback)
        })
      }
    })

    // enable rating of ideas
    $('#ideas').on('click', '.rate', (e) => {

      const idea_id = $(e.currentTarget).data('idea')
      const rating = $(e.currentTarget).data('rating')

      channel.push('rate_idea', { id: idea_id, rating })
      .receive("ok", ({ my_rating, raters, rating }) => {
        const idea = $(`#idea${idea_id}`)

        // update and show overall rating and raters
        idea.find('.rating').show().children('strong').text(rating)
        idea.find('.raters').show().children('strong').text(raters)

        // update and show user rating
        idea.find('.user-rating strong').text(my_rating).show()
        idea.find('.user-rating small').hide()
        $(`#idea${idea_id} .user-rating i`).addClass('text-primary')

        // update and hide stars
        idea.find('.star-rating').hide()
          .find('button').removeClass('text-primary').addClass('text-muted')
        for(let i = 1; i <= rating; i++){
          idea.find(`[data-rating="${i}"]`)
            .addClass('text-primary').removeClass('text-muted')
        }
      })
    })

    // enable unrating of ideas
    $('#ideas').on('click', '.unrate', (e) => {

      const idea_id = $(e.currentTarget).data('idea')

      channel.push('unrate_idea', { id: idea_id })
      .receive("ok", ({ raters, rating }) => {
        const idea = $(`#idea${idea_id}`)

        // update and show overall rating and raters
        idea.find('.rating').show().children('strong').text(rating)
        idea.find('.raters').show().children('strong').text(raters)

        // update and hide user rating
        idea.find('.user-rating strong').text('').hide()
        idea.find('.user-rating small').show()
        $(`#idea${idea_id} .user-rating i`).removeClass('text-primary')

        // update and hide stars
        idea.find('.star-rating').hide()
          .find('button').removeClass('text-primary').addClass('text-muted')
      })
    })

    // enable like and unlike
    $('#ideas').on('click', 'a.like', (e) => {
      e.preventDefault()
      const elm = $(e.target)
      channel.push('like', {
        comment_id: elm.data('comment-id'),
        like: elm.text() != "Unlike"
      }).receive("ok", () => {

        const elmLikes = elm.siblings('span')
        let likes = parseInt(elmLikes.text())

        // was unliked
        if(elm.text() == "Unlike"){
          likes--;
          elmLikes.text(likes)
          elm.text("Like")
          if(likes == 0) elmLikes.addClass('d-none')
        }
        // was liked
        else {
          likes++;
          elmLikes.text(likes).removeClass('d-none')
          elm.text("Unlike")
        }
      })
    })

    // join and schedule loading of future ideas, comments, likes, and ratings
    channel.join().receive('ok', ({ ideas, comments, likes, ratings }) => {
      for(let i=0; i < ideas.length; i++) this.schedule_idea(ideas[i]);
      for(let i=0; i < comments.length; i++) this.schedule_comment(comments[i]);
      for(let i=0; i < likes.length; i++) this.schedule_like(likes[i]);
      for(let i=0; i < ratings.length; i++) this.schedule_rating(ratings[i]);
    })
  }

  mount() {
    super.mount();

    // connect socket and join topic_channel
    this.joinChannel()

    // if experiment is in progress, enable "finish" btn after timer runs out
    let countdown = $('#timer').data('remaining');
    if (countdown) {
      setTimeout(() => {
        $('#timer').addClass('d-none');
        $('#btn-complete').removeClass('d-none');
      }, countdown * 1000);
    }

    // toggles star rating for submitting a user rating
    $("body").on('click', '.user-rating', (e) => {
      $(e.currentTarget).siblings().toggle()
    })

    // enable delayed ideas that are not yet posted
    $('.idea.d-none').each(function(){
      const elm = this
      setTimeout(function(){
        $(elm).removeClass('d-none').addClass('new').parent().prepend(elm)
      }, $(elm).data('remaining') * 1000)
    })

    // enable delayed comments that are not yet posted
    $('.comment.d-none').each(function(){
      const elm = this
      setTimeout(function(){
        $(elm).removeClass('d-none').addClass('new').parent().append(elm)
      }, $(elm).data('remaining') * 1000)
    })
  }

  unmount() {
    super.unmount();
    $('#timer').remove();
    $('#btn-complete').remove();
  }
}
