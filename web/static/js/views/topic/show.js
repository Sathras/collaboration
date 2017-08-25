// web/static/js/views/topic/show.js

import $ from 'jquery'
import List from 'list.js'
import socket from '../../socket'
import MainView from '../main';

export default class View extends MainView {
  mount() {
    super.mount();

    const topic_id = $('#topic').data('id')

    // prepare the idea list
    var list_options = {
      item: 'idea-item',
      valueNames: [
        {data: ['id']},
        'title',
        'description',
        'user'
      ]
    }

    // create empty idea list
    var ideaList = new List('idea-list', list_options, [])

    // define and join topicChannel
    let channel = socket.channel(`topic:${topic_id}`)
    channel.join()
      // on load retrieve list of ideas from server
      .receive("ok", ({ideas}) => {

        console.log(ideas)

        // render a list of ideas
        ideaList.add( ideas, (ideas) => {
          // add comments to each item
          ideas.forEach((i) => {
            i.values().comments.forEach(c => {
              $(`.idea[data-id=${c.id}]`).children('.comments').append(`
                <li class="comment list-group-item" data-id="${c.id}">
                  <strong>${c.user}: </strong>
                  ${c.text}
                  <div class='pl-2 pull-right'>
                    <i>4 minutes ago</i>
                    <button type="button" class="btn btn-light btn-sm">
                      <i class="fa fa-trash" aria-hidden="true"></i>
                    </button>
                  </div>
                </li>
              `)
            })
          })
        })
      })
      .receive("error", resp => { console.log("Unable to join", resp) })

  }

  unmount() {
    super.unmount();

  }

  renderIdea({id, title, description, user, comments}){

    $('#idea-container').prepend(`
    <div data-id="${id}" class="idea card mb-1">
      <div class="card-body">
        <h4 class="card-title">${title}</h4>
        <h6 class="card-subtitle mb-2 text-muted">${user.firstname} ${user.lastname}</h6>
        ${description}
        <ul class="comments list-group"></ul>
      </div>
    </div>
    `)

    if(window.editTopic) $(`.idea[data-id=${id}]`)
      .append('EDIT')
    // const commentList = comments.forEach( c => this.renderComment(c))
  }
}




//   $('#submit-idea').submit(e => {
//     e.preventDefault()

//     let payload = {
//       title: $('#idea_title').val(),
//       description: $('#idea_description').val(),
//       user_id: $('#idea_user_id').val()
//     }

//     topicChannel.push("new_idea", payload)
//       .receive("ok", (idea) => {
//         window.location.reload(true);
//       })
//       .receive("error", (data) => {

//         $("#idea_alert").removeClass('d-none')

//         if(data.errors.title)
//           $('#idea_title')
//             .addClass('is-invalid')
//             .siblings('.invalid-feedback').html(data.errors.title[0])
//         else
//           $('#idea_title').addClass('is-valid')

//         if(data.errors.description)
//           $('#idea_description')
//             .addClass('is-invalid')
//             .siblings('.invalid-feedback').html(data.errors.description[0])
//         else
//           $('#idea_title').addClass('is-valid')
//       })

//     $('#idea_title').val("")
//     $('#idea_description').val("")
//     $('#idea_user_id').val("")
//   })

//   $('.add-comment').submit((e) => {
//     e.preventDefault()

//     let payload = {
//       text: $(e.currentTarget).find('.comment-text').val(),
//       idea_id: $(e.currentTarget).find('.comment-idea').val()
//     }

//     topicChannel.push("new_comment", payload)
//       .receive("error", e => console.log(e) )
//     $('.comment-text').val("")
//   })

//   topicChannel.on("new_idea", (idea) => {
//     renderIdea(idea)
//   })


// }

// function esc(str){
//   let div = document.createElement("div")
//   div.appendChild(document.createTextNode(str))
//   return div.innerHTML
// }

// function renderIdea(idea){
//   // TODO append annotation to msgContainer
//   console.log(idea)

//   // let template = document.createElement("div")

//   // template.innerHTML = `
//   // <a href="#" data-seek="${this.esc(at)}">
//   //   <b>${this.esc(user.username)}</b>: ${this.esc(body)}
//   // </a>
//   // `
//   // msgContainer.appendChild(template)
//   // msgContainer.scrollTop = msgContainer.scrollHeight

// }
