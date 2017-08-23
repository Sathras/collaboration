import $ from 'jquery'
import socket from "./socket"

// Now that you are connected, you can join channels with a topic:
const topic_id = (document.getElementById("topic"))
  ? document.getElementById("topic").getAttribute("data-id")
  : ""

let topicChannel = socket.channel(`topic:${topic_id}`)

if(topic_id){

  topicChannel.join()
    .receive("ok", resp => { console.log("Joined successfully", resp) })
    .receive("error", resp => { console.log("Unable to join", resp) })


  $('#submit-idea').submit(e => {
    e.preventDefault()

    let payload = {
      title: $('#idea_title').val(),
      description: $('#idea_description').val(),
      user_id: $('#idea_user_id').val()
    }

    topicChannel.push("new_idea", payload)
      .receive("ok", (idea) => {
        window.location.reload(true);
      })
      .receive("error", (data) => {

        $("#idea_alert").removeClass('d-none')

        if(data.errors.title)
          $('#idea_title')
            .addClass('is-invalid')
            .siblings('.invalid-feedback').html(data.errors.title[0])
        else
          $('#idea_title').addClass('is-valid')

        if(data.errors.description)
          $('#idea_description')
            .addClass('is-invalid')
            .siblings('.invalid-feedback').html(data.errors.description[0])
        else
          $('#idea_title').addClass('is-valid')
      })

    $('#idea_title').val("")
    $('#idea_description').val("")
    $('#idea_user_id').val("")
  })

  $('.add-comment').submit((e) => {
    e.preventDefault()

    let payload = {
      text: $(e.currentTarget).find('.comment-text').val(),
      idea_id: $(e.currentTarget).find('.comment-idea').val()
    }

    topicChannel.push("new_comment", payload)
      .receive("error", e => console.log(e) )
    $('.comment-text').val("")
  })

  topicChannel.on("new_idea", (idea) => {
    renderIdea(idea)
  })


}

function esc(str){
  let div = document.createElement("div")
  div.appendChild(document.createTextNode(str))
  return div.innerHTML
}

function renderIdea(idea){
  // TODO append annotation to msgContainer
  console.log(idea)

  // let template = document.createElement("div")

  // template.innerHTML = `
  // <a href="#" data-seek="${this.esc(at)}">
  //   <b>${this.esc(user.username)}</b>: ${this.esc(body)}
  // </a>
  // `
  // msgContainer.appendChild(template)
  // msgContainer.scrollTop = msgContainer.scrollHeight

}

export default topicChannel